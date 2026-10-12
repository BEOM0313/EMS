# 메디패스 자체 OSRM 길찾기 서버

메디패스는 기본으로 공개 OSRM 서버(FOSSGIS, routing.openstreetmap.de)를 씁니다. 공개 서버는 무료지만 사용 정책상 요청이 많으면 제한될 수 있어, 실제 운영에서는 이 폴더로 **한국 지도만 넣은 OSRM 서버**를 직접 띄우는 것을 권장합니다. 엔진은 [Project-OSRM/osrm-backend](https://github.com/Project-OSRM/osrm-backend)입니다.

## 필요한 것
- Docker (Docker Compose 포함)
- 메모리 4GB 이상 권장, 디스크 수 GB

## 실행
```bash
cd osrm
./prepare.sh          # 한국 지도 내려받기 + 차량·도보 경로 데이터 만들기 (처음 한 번)
docker compose up -d  # 서버 켜기 (포트 8088)
```
확인: `http://localhost:8088/routed-car/route/v1/driving/126.97797,37.56654;126.97689,37.57592`

지도를 최신으로: `./prepare.sh --update && docker compose restart car foot`

## 앱에 연결
앱 오른쪽 위 설정(데이터 연결) → **길찾기 서버**에 주소 입력 → **서버 확인** → 새로고침.
- 자체 서버가 응답하지 않으면 앱이 공개 OSRM 서버로 자동 전환합니다. 지도 아래 문구에 어느 서버를 썼는지 표시됩니다.
- 앱을 GitHub Pages(https)로 열 때는 길찾기 서버도 **https 주소**여야 합니다 (브라우저가 https 페이지에서 http 호출을 막음). 같은 컴퓨터의 `http://localhost:8088`은 예외로 허용됩니다. 외부 공개는 Caddy·Cloudflare Tunnel 등으로 https를 붙이세요.

## 앱이 쓰는 OSRM 기능
- `table`: 출발지 1곳 → 가까운 응급실 25곳 차량·도보 시간을 한 번에 계산 (`--max-table-size 500`)
- `route`: 추천 병원까지 경로 선

실시간 교통은 반영되지 않습니다 (오픈스트리트맵 도로 + 평균 속도).
