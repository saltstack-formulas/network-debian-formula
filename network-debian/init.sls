# network states
# setup basic network configuration based on pillar data
#

{%- from 'network-debian/map.jinja' import map with context %}

# remove resolvconf package - we want to control resolv.conf ourselves.
#
{%- if 'network' in pillar %}
network_remove_resolvconf:
  pkg.removed:
    - name: resolvconf

{%- set network = salt['pillar.get']('network', {}) %}
{%- set interfaces = network.get('interfaces', {}) %}
{%- if not interfaces is mapping or not interfaces.get('keep', false) %}
/etc/network/interfaces:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - source:   salt://network-debian/files/interfaces.jinja
    - context:
      interfaces: {{ pillar.network.get('interfaces',{}) }}
{%- endif %}

/etc/network/routes:
  file.managed:
    - user: root
    - group: root
    - mode: 755
    - template: jinja
    - source:   salt://network-debian/files/routes.jinja
    - context:
      interfaces: {{ pillar.network.get('interfaces',{}) }}
      routes: {{ pillar.network.get('routes',{}) }}

/etc/resolv.conf:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - source:   salt://network-debian/files/resolvconf.jinja
    - context:
      dnsserver: {{ pillar.network.get('dnsserver',[]) }}
      dnsdomain: {{ pillar.network.get('dnsdomain', 'localnet') }}
      dnssearch: {{ pillar.network.get('dnssearch', []) }}
{%- endif %}
