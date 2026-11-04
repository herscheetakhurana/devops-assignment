#!/usr/bin/env bash
# ============================================================
# Lab 3 - ELK Stack + Prometheus/Grafana Setup
# ============================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR/../monitoring-configs"

echo "==============================="
echo " Starting Monitoring Stack"
echo "==============================="

cd "$CONFIG_DIR"

echo "[1/4] Starting Elasticsearch, Logstash, Kibana..."
docker compose -f docker-compose-monitoring.yml up -d elasticsearch logstash kibana

echo "Waiting for Elasticsearch to be ready..."
until curl -s http://localhost:9200/_cluster/health | grep -q '"status":"green"\|"status":"yellow"'; do
    echo "  Waiting..."
    sleep 5
done
echo "Elasticsearch is ready."

echo "[2/4] Starting Prometheus, Alertmanager, Grafana..."
docker compose -f docker-compose-monitoring.yml up -d prometheus alertmanager grafana node-exporter cadvisor

echo "[3/4] Verifying services..."
sleep 10

echo ""
echo "Service Status:"
docker compose -f docker-compose-monitoring.yml ps

echo ""
echo "[4/4] Service URLs:"
echo "  Prometheus:    http://localhost:9090"
echo "  Alertmanager:  http://localhost:9093"
echo "  Grafana:       http://localhost:3001  (admin/devops123)"
echo "  Elasticsearch: http://localhost:9200"
echo "  Kibana:        http://localhost:5601"
echo "  cAdvisor:      http://localhost:8080"
echo ""
echo "Monitoring stack is UP!"
