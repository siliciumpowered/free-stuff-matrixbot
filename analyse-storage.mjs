import fs from "fs";

main();

function main() {
    const storage = loadStorageContent("storage.json");
    const extraction = extract(storage, 8, 5);
    console.info(humanReadable(extraction));
}

function loadStorageContent(storageFilePath) {
    return JSON.parse(fs.readFileSync(storageFilePath).toString());
}

function extract(storage, limitPerHostname = 100, minimalNumberOfTitles = 0) {
    const extraction = new Map();
    storage.posts_seen
        .filter(post => !post.skip)
        .reverse()
        .forEach(post => {
            const hostname = new URL(post.url).hostname.toString();
            if (extraction.has(hostname)) {
                const titles = extraction.get(hostname);
                if (titles.size < limitPerHostname) {
                    titles.add(post.title);
                }
            } else {
                const titles = new Set();
                titles.add(post.title);
                extraction.set(hostname, titles);
            }
        });
    for (let [hostname, titles] of extraction) {
        if (titles.size < minimalNumberOfTitles) {
            extraction.delete(hostname);
        }
    }
    return extraction;
}

function humanReadable(extraction) {
    let humanReadable = '';
    let maxHostnameLength = -1;
    for (let hostname of extraction.keys()) {
        if (hostname.length > maxHostnameLength) {
            maxHostnameLength = hostname.length;
        }
    }
    for (let [hostname, titles] of extraction) {
        humanReadable += hostname + ' '.repeat(maxHostnameLength - hostname.length + 1);
        let firstTitle = true;
        for (let title of titles) {
            if (firstTitle) {
                firstTitle = false;
            } else {
                humanReadable += ' '.repeat(maxHostnameLength + 1);
            }
            humanReadable += `${title.substring(0, 100)}\n`;
        }
    }
    return humanReadable;
}
