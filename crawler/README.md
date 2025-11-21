# HUHU Crawler

간단한 설명: 본 프로젝트는 여러 한국 커뮤니티 및 포럼(예: dcinside, fmkorea, ruliweb, theqoo 등)의 게시글을 주기적으로 크롤링하여 로그 디렉터리에 저장하는 파이썬 기반 크롤러입니다.

## 주요 기능

- 여러 서비스별 크롤러를 모듈화하여 관리
- 배치 파일(`crawl_schedule.bat`, `main_crawl.bat`)을 통한 스케줄 실행 지원
- 실행 로그를 `logs/` 디렉터리에 저장

## 저장소 구조

- `core/`: 공통 모듈 및 셀레니움 유틸리티 (`pyselenium.py`)
- `services/`: 서비스별 크롤러와 설정(`*.yaml`) 파일
  - `dcinside/`, `fmkorea/`, `ruliweb/`, `theqoo/` 등
- `logs/`: 서비스별 수집 결과 및 로그
- `utils/logger.py`: 프로젝트 로깅 유틸리티
- `main_crawl.py`: 크롤러 실행 엔트리 포인트
- `crawl_schedule.bat`, `main_crawl.bat`: Windows에서의 스케줄/실행 스크립트

## 요구사항

- Python 3.13 이상 권장
- 필요한 패키지는 `requirements.txt`에 정의되어 있습니다.

## 설치 (Windows, PowerShell 예시)

1. 가상환경 생성 및 활성화

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
```

2. 의존성 설치

```powershell
pip install -r requirements.txt
```

## 실행 방법

- 수동 실행 (PowerShell)

```powershell
python main_crawl.py
```

- 배치 파일 사용 (Windows Task Scheduler에 등록 가능)

```powershell
./main_crawl.bat
# 또는
./crawl_schedule.bat
```

## 설정

- 서비스별 설정 파일은 각 서비스 폴더 내의 `*.yaml` 파일을 편집합니다. 예: `services/dcinside/dc_best_crawl.yaml`
- `core/pyselenium.py`에서 브라우저(예: Chrome) 설정 및 드라이버 경로를 확인/수정하세요.

## 로그 및 출력

- 크롤링 결과 및 로그는 `logs/<service>/` 폴더에 저장됩니다. 예: `logs/dcinside/`

## 개발 가이드 (새 서비스 추가 시)

1. `services/` 내부에 새 폴더 생성 (예: `example/`)
2. 크롤러 스크립트(`example_crawl.py`)와 설정 파일(`example_crawl.yaml`) 추가
3. `main_crawl.py` 또는 스케줄러에서 새 서비스 호출 로직을 추가

## 문제 해결 팁

- 셀레니움 관련 문제는 브라우저 드라이버 버전(ChromeDriver 등)과 Chrome/브라우저 버전이 일치하는지 확인하세요.
- 권한이나 경로 문제는 PowerShell을 관리자 권한으로 실행하여 확인해보세요.

## 기여

- 이 저장소에 기여하려면 이슈를 열거나 풀 리퀘스트를 제출하세요. 간단한 변경사항은 직접 브랜치를 만들어 풀 리퀘스트를 보내주시면 됩니다.

## 라이선스

- 프로젝트에 별도 명시가 없을 경우 내부 규칙을 따르세요. 공개용으로 배포하려면 적절한 라이선스를 추가하세요.

---

파일 위치: `README.md`

필요하시면 영어 버전이나 더 상세한 실행/디버그 섹션, 예제 로그 파일 샘플 등을 추가로 만들어 드리겠습니다.
