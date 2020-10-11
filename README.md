# free-stuff-matrixbot
The _free-stuff-matrixbot_ is a very simple bot that discovers and sends current deals and sales to a specified [Matrix](https://matrix.org/) channel. It is build with [matrix-nio](https://github.com/poljar/matrix-nio) and _does not support e2ee so far_. Currently, only deals on games posted to the subreddit [/r/GameDeals](https://old.reddit.com/r/GameDeals/) are discovered and reported.

## Deployment
The deployment is configured via environment variables.
Consider using a `.env` file to store the configuration.
It is respected by `docker-compose` and by the Makefile \(for the secret creation\).

The required entries are `HOMESERVER_URL`, `BOT_USER`, `BOT_PASSWORD`, `ROOM_ID` and `URL_SKIP`.
Additionally `LOG_LEVEL` and `LOG_FORMAT` are also supported.

When running the bot manually \(not with one of the provided container configurations\) `STORAGE_FILE` has to be set, too. 

## Contributing
If you feel like contributing, Pull Requests are welcome! Please follow the [PEP 8 Style Guide](https://www.python.org/dev/peps/pep-0008/) for the Python code.

### Setting up a development environment
1. **Python environment**: This bot uses the python version specified in the [`.python-version`](.python-version) file. Please make sure that your code runs with this version as expected. We suggest [pyenv](https://github.com/pyenv/pyenv) to manage and install arbitrary versions on a project-by-project basis.
2. **Install python packages**: All python necessary to run the code are specified in the [`requirements.txt`](requirements.txt) file. To install them using pip, run:
    ```shell
    $ pip install -r requirements.txt
    ```
3. **Lint your code**: To ensure consequent coding guidelines, this project generally follows the [PEP 8 Style Guide](https://www.python.org/dev/peps/pep-0008/) for Python code. This is enforced using the [flake8 linter](https://gitlab.com/pycqa/flake8). You can either install it as an extension to your IDE/editor or use the command line. See the project's homepage for more details on this.
4. **Run the code**: We suggest to use docker-compose with the [`docker-compose.yml`](docker-compose.yml) file to run the bot. This maximizes the chances of reproducibility on all sides, making reviewing changes and verifying bugs easier for everyone.

## License
[Apache License 2.0](LICENSE)
