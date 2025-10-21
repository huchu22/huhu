from selenium import webdriver
from selenium.webdriver.chrome.options import Options

class Pyselenium:
    def __init__(self, user_agent=None):
        chrome_options = Options()

        # 기본 User-Agent
        default_agent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"

        # YAML 등에서 넘어온 게 있으면 덮어쓰기
        agent = user_agent or default_agent

        chrome_options.add_argument(f"user-agent={agent}")
        chrome_options.add_argument("--headless=new")  # 필요 시
        chrome_options.add_argument("--no-sandbox")
        chrome_options.add_argument("--disable-dev-shm-usage")

        self.driver = webdriver.Chrome(options=chrome_options)
