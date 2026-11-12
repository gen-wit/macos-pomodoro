"""Builds ../Pomodoro-manual.pdf from manual.html (needs: pip install playwright; playwright install chromium)."""
import asyncio, pathlib
from playwright.async_api import async_playwright

HERE = pathlib.Path(__file__).resolve().parent

async def main():
    async with async_playwright() as p:
        b = await p.chromium.launch()
        pg = await b.new_page()
        await pg.goto((HERE / "manual.html").as_uri())
        await pg.wait_for_load_state("networkidle")
        await pg.evaluate("document.fonts.ready")
        await pg.pdf(path=str(HERE.parent / "Pomodoro-manual.pdf"),
                     prefer_css_page_size=True, print_background=True)
        await b.close()

asyncio.run(main())
