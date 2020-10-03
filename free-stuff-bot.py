import os
import pathlib
import requests
from lxml import html

import matrixbz
import matrixbz.response as response
import matrixbz.cache as cache

XKCD_PATH = pathlib.Path(__file__).parent.absolute()
CACHE_PATH = os.path.join(XKCD_PATH, 'responsecache')


@matrixbz.matrixbz_controller(bot_name='xkcdbot')
class XKCDBotController():

    AUTH = matrixbz.auth.PublicBot
    CACHE = cache.FileTextCache(CACHE_PATH)

    @cache.cache_result
    @matrixbz.matrixbz_method
    async def num(self, num, **kwargs):
        page_url = f'https://xkcd.com/{num}/'
        img_url = self._get_img_url(page_url)
        return response.Image(img_url)

    def _get_img_url(self, url):
        res = requests.get(url)
        tree = html.fromstring(res.text)
        img_url = tree.xpath('//div[@id="comic"]/img')[0].get('src')
        return f'https:{img_url}'


creds = {
    'homeserver': 'https://matrix.MYSERVER.com',
    'user': '@bot:MYSERVER.com',
    'password': 'bot_password'
}

bot = XKCDBotController.create_matrix_bot(creds)
bot.run()
