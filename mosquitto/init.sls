{% from "mosquitto/map.jinja" import mosquitto with context %}

bootstrap-mosquitto:
  pkg.installed:
    - pkgs:  {{ mosquitto.deps }}

  group.present:
    - name: {{ mosquitto.user }}

  user.present:
    - name: {{ mosquitto.user }}
    - fullname: "Mosquitto Broker"
    - createhome: false
    - system: true
    - gid_from_name: true
    - require:
        - group: bootstrap-mosquitto


create-mosquitto-directories:
  file.directory:
    - user: {{ mosquitto.user }}
    - group: {{ mosquitto.user }}
    - mode: 775
    - makedirs: true
    - names:
        - {{ mosquitto.log_dir }}
        - {{ mosquitto.config_dir }}
        - {{ mosquitto.data_dir }}
        - {{ "%s/share/man/man8/mosquitto.8"|format(mosquitto.prefix) }}
    - recurse:
        - user
        - group

    - require:
        - user: bootstrap-mosquitto

fetch-mosquitto-archive:
  archive.extracted:
    - name: {{ mosquitto.prefix }}
    - source: {{ mosquitto.source_url % mosquitto }}
    - source_hash: {{ mosquitto.source_hash }}
    - archive-format: tar
    - require:
        - file: create-mosquitto-directories
        - user: bootstrap-mosquitto

  alternatives.install:
    - name: mosquitto-home
    - link: {{ mosquitto.alt_root }}
    - path: {{ mosquitto.real_root }}
    - priority: 999
    - require:
        - archive: fetch-mosquitto-archive
