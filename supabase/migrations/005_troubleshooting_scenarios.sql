-- Migration 005: Seed troubleshooting scenarios (Phase 8)
-- Idempotent: ON CONFLICT DO NOTHING by slug.

insert into public.troubleshooting_scenarios (
  slug, title, description, difficulty, skill_id,
  initial_state, allowed_commands, states, transitions, hints,
  root_cause, repair_action, verification, scoring_rules, is_published
) values (
  'dns-failure',
  'Broken DNS Resolution',
  'Application can''t resolve external hostnames, but ICMP to a public IP succeeds. Diagnose the resolver.',
  'beginner',
  (select id from public.skills where slug = 'ip-addressing' limit 1),
  'dns_failure',
  '["ping 8.8.8.8","cat /etc/resolv.conf","nslookup example.com","ip route","systemctl restart systemd-resolved"]'::jsonb,
  '{
    "dns_failure": {
      "description": "DNS resolver is unreachable",
      "responses": {
        "ping 8.8.8.8": "64 bytes from 8.8.8.8: icmp_seq=1 ttl=118 time=12.4 ms\n--- 8.8.8.8 ping statistics ---\n1 packets transmitted, 1 received, 0% packet loss",
        "cat /etc/resolv.conf": "nameserver 127.0.0.53\n# invalid upstream",
        "nslookup example.com": ";; connection timed out; no servers could be reached",
        "ip route": "default via 192.168.1.1 dev eth0\n192.168.1.0/24 dev eth0 scope link"
      }
    },
    "resolved": {
      "description": "Service restored",
      "resolved": true
    }
  }'::jsonb,
  '[
    {"from":"dns_failure","command":"systemctl restart systemd-resolved","to":"resolved","output":"Job for systemd-resolved.service restarted.\nVerification: nslookup example.com now returns 93.184.216.34"}
  ]'::jsonb,
  '[
    "Investigate how your machine turns names into IPs.",
    "The networking/DNS subsystem is responsible for this translation.",
    "Try cat /etc/resolv.conf to see which resolver is configured.",
    "The configured nameserver (127.0.0.53) is unreachable.",
    "Replace the broken resolver with a working one (e.g. 8.8.8.8) and restart systemd-resolved."
  ]'::jsonb,
  'The configured DNS resolver is unreachable.',
  'Replace the invalid resolver with a working resolver and restart the DNS service.',
  'nslookup example.com returns a valid IP address.',
  '{}'::jsonb,
  true
) on conflict (slug) do nothing;

insert into public.troubleshooting_scenarios (
  slug, title, description, difficulty, skill_id,
  initial_state, allowed_commands, states, transitions, hints,
  root_cause, repair_action, verification, scoring_rules, is_published
) values (
  'nginx-stopped',
  'Web Server Down',
  'A web application that was previously reachable on localhost is now returning connection refused. Investigate and restore.',
  'beginner',
  (select id from public.skills where slug = 'linux-cli' limit 1),
  'nginx_stopped',
  '["systemctl status nginx","journalctl -u nginx -n 50","ss -tulpn","curl localhost","systemctl start nginx"]'::jsonb,
  '{
    "nginx_stopped": {
      "description": "nginx is not running",
      "responses": {
        "systemctl status nginx": "● nginx.service - The nginx HTTP and reverse proxy server\n   Active: inactive (dead) since Tue 2026-09-16 10:00:00 UTC",
        "journalctl -u nginx -n 50": "-- Logs begin at Tue 2026-09-16 09:00:00 UTC --\nSep 16 10:00:00 host1 systemd[1]: Stopping nginx HTTP and reverse proxy server...\nSep 16 10:00:01 host1 systemd[1]: Stopped nginx HTTP and reverse proxy server.",
        "ss -tulpn": "(empty - nothing listening on 80/443)",
        "curl localhost": "curl: (7) Failed to connect to localhost port 80: Connection refused"
      }
    },
    "resolved": {"description": "Service restored", "resolved": true}
  }'::jsonb,
  '[
    {"from":"nginx_stopped","command":"systemctl start nginx","to":"resolved","output":"Job for nginx.service started.\nVerification: curl localhost returns HTTP 200 with the nginx default page."}
  ]'::jsonb,
  '[
    "Investigate the layer where the web traffic terminates.",
    "This is a Linux service management issue.",
    "Try systemctl status nginx to inspect the service state.",
    "The service is in inactive (dead) state.",
    "Start the nginx service with systemctl start nginx."
  ]'::jsonb,
  'Nginx is stopped.',
  'Start the nginx service.',
  'curl localhost returns an HTTP response (200 OK).',
  '{}'::jsonb,
  true
) on conflict (slug) do nothing;

insert into public.troubleshooting_scenarios (
  slug, title, description, difficulty, skill_id,
  initial_state, allowed_commands, states, transitions, hints,
  root_cause, repair_action, verification, scoring_rules, is_published
) values (
  'disk-full',
  'Disk Full',
  'A server reports write failures on its main volume. Diagnose the storage subsystem and free space.',
  'intermediate',
  (select id from public.skills where slug = 'linux-cli' limit 1),
  'disk_full',
  '["df -h","du -sh /var/log","journalctl --vacuum-size=100M"]'::jsonb,
  '{
    "disk_full": {
      "description": "Filesystem at 100%",
      "responses": {
        "df -h": "Filesystem      Size  Used Avail Use% Mounted on\n/dev/sda1       20G   20G     0 100% /"
      }
    },
    "resolved": {"description": "Filesystem reclaimed", "resolved": true}
  }'::jsonb,
  '[
    {"from":"disk_full","command":"journalctl --vacuum-size=100M","to":"resolved","output":"Vacuuming done, freed 1.4G of journal archives.\nVerification: df -h shows 5G available."}
  ]'::jsonb,
  '[
    "Look at where growing data accumulates on Linux servers.",
    "Logs are a common culprit.",
    "Try du -sh /var/log or journalctl disk usage.",
    "Old journal archives are eating the volume.",
    "Vacuum old logs: journalctl --vacuum-size=100M."
  ]'::jsonb,
  'A filesystem is at or near 100% capacity due to bloated logs.',
  'Identify and remove/rotate the offending data according to the scenario rules.',
  'df -h shows sufficient free space.',
  '{}'::jsonb,
  true
) on conflict (slug) do nothing;
