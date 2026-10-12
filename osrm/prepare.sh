#!/usr/bin/env bash
# 메디패스용 OSRM 지도 데이터 만들기 (대한민국, 차량 + 도보)
# 공식 osrm-backend 안내(https://github.com/Project-OSRM/osrm-backend#using-docker)의 MLD 절차를 그대로 따른다.
#   1) 오픈스트리트맵 한국 데이터 내려받기 (Geofabrik, 약 250MB 안팎)
#   2) osrm-extract → osrm-partition → osrm-customize (프로필마다 따로)
# 처음 한 번, 그리고 지도를 새로 고치고 싶을 때(예: 매달) 실행한다. 메모리 4GB 이상 권장.
set -euo pipefail
cd "$(dirname "$0")"
IMAGE="${OSRM_IMAGE:-ghcr.io/project-osrm/osrm-backend:v5.27.1}"
PBF_URL="https://download.geofabrik.de/asia/south-korea-latest.osm.pbf"
mkdir -p data/car data/foot

if [ ! -f data/south-korea-latest.osm.pbf ] || [ "${1:-}" = "--update" ]; then
  echo "▶ 지도 데이터 내려받는 중: $PBF_URL"
  curl -fL -o data/south-korea-latest.osm.pbf.part "$PBF_URL"
  mv data/south-korea-latest.osm.pbf.part data/south-korea-latest.osm.pbf
fi

for profile in car foot; do
  echo "▶ [$profile] 경로 데이터 만드는 중"
  cp data/south-korea-latest.osm.pbf "data/$profile/korea.osm.pbf"
  docker run --rm -t -v "$PWD/data/$profile:/data" "$IMAGE" osrm-extract -p "/opt/$profile.lua" /data/korea.osm.pbf
  docker run --rm -t -v "$PWD/data/$profile:/data" "$IMAGE" osrm-partition /data/korea.osrm
  docker run --rm -t -v "$PWD/data/$profile:/data" "$IMAGE" osrm-customize /data/korea.osrm
  rm -f "data/$profile/korea.osm.pbf"
done
echo "✔ 완료. 이제 'docker compose up -d'로 서버를 켜세요."
