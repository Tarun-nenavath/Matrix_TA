=====================NOTEBOOK======================

Challenge Summary:
Successfully fixed operational, networking, integrity validation and health monitoring issues in the EO/IR perception stack.

Issue 1 – Incorrect Service Discovery and Port Configuration
File: docker-compose.yml

Problem: vision_api attempted to communicate with inference_worker using an incorrect endpoint and localhost.

Impact: 
Startup handshake failed.
vision_api could not communicate with inference_worker.
Health endpoint returned degraded status.
Detection requests failed because worker validation could not be completed.

Fix: Changed WORKER_URL from http://localhost:9001 to http://inference_worker:9000



Issue 2 – Network Isolation
File: docker-compose.yml

Problem: vision_api and inference_worker were attached to different Docker networks.

Impact: Containers could not communicate.

Fix: Attached inference_worker to both sensor_backplane and edge_dmz.




Issue 3 – Model Checksum Mismatch
File: models/manifest.json

Problem: Manifest SHA256 did not match model artifact.

Impact: Worker validation failed and returned HTTP 500.

Fix: Validated actual checksum and updated manifest.

Verification: python -m unittest discover -s tests

Status: PASS






Issue 4 – Startup State Logic
File: vision_api/app.py

Problem: Worker readiness was permanently tied to startup state.

Impact: vision_api remained degraded even after worker recovered.

Fix: Changed readiness checks to evaluate current worker state using check_worker().






Issue 5 – Fake Healthcheck
File: docker-compose.yml

Problem: Healthcheck always returned success.

Impact: Docker reported healthy even when inference failed.

Fix: Replaced echo-based healthcheck with application-aware endpoint validation.

Verification: Container transitions to unhealthy when model integrity validation fails.





Issue 6 – Hardcoded Secrets
File: docker-compose.yml

Problem: Database passwords and AWS secret stored directly in version control.

Fix: Moved runtime configuration into .env. Added .env.example template.

Deployment
docker compose up -d --build

Validation
curl http://localhost:8000/health

curl http://localhost:8000/api/v1/detect

Field Rollback Procedure
Stop inference_worker
docker compose stop inference_worker

Restore previous approved engine
cp models/backup/eo_detector_fp16.engine models/eo_detector_fp16.engine

Verify checksum
sha256sum eo_detector_fp16.engine

Start worker
docker compose up -d inference_worker

Validate service
curl http://localhost:8000/health

curl http://localhost:8000/api/v1/detect

