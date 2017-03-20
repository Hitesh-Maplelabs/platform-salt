{% from "graphite-api/map.jinja" import config with context %}

graphite-api-carbon-install:
  pkg.installed:
    - name: {{ config.carbon_package }}

graphite-api-carbon-configure:
  file.managed:
    - name: /etc/carbon/storage-schemas.conf
    - source: salt://graphite-api/files/storage-schemas.conf
    - require:
      - pkg: graphite-api-carbon-install

{% if grains['os_family'] == 'Debian' %}
graphite-api-carbon-enable-ubuntu:
  file.managed:
    - name: /etc/default/graphite-carbon
    - source: salt://graphite-api/files/graphite-carbon.default
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: graphite-api-carbon-install
{% endif %}

graphite-api-carbon-enable-and-start:
  service.running:
    - name: carbon-cache
    - enable: True
    - watch:
      - pkg: graphite-api-carbon-install
      - file: graphite-api-carbon-configure
{% if grains['os_family'] == 'Debian' %}
      - file: graphite-api-carbon-enable-ubuntu
{% endif %}

graphite-api-install-graphite:
  pkg.installed:
{% if grains['os_family'] == 'RedHat' %}
    - name: graphite-api
{% elif grains["os_family"] == 'Debian' %}
    - sources:
      - graphite-api: https://github.com/brutasse/graphite-api/releases/download/1.1.2/graphite-api_1.1.2-1447943657-ubuntu14.04_amd64.deb
{% endif %}

graphite-api-configure-default:
  file.managed:
    - name: {{ config.graphite_api_default }}
    - source: salt://graphite-api/files/{{ config.graphite_api_default_src }}

graphite-api-configure:
  file.managed:
    - name: /etc/graphite-api.yaml
{% if grains['os_family'] == 'RedHat' %}
    - source: salt://graphite-api/files/graphite-api.yaml.redhat
{% elif grains["os_family"] == 'Debian' %}
    - source: salt://graphite-api/files/graphite-api.yaml.debian
{% endif %}

graphite-api-enable-and-start:
  service.running:
    - name: graphite-api
    - enable: True
    - watch:
      - pkg: graphite-api-install-graphite
      - file: graphite-api-configure-default
      - file: graphite-api-configure
