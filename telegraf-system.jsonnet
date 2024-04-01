local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';

local panels = import './panels.libsonnet';
local queries = import './queries.libsonnet';
local variables = import './variables.libsonnet';

g.dashboard.new('Telegraf / System')
+ g.dashboard.withUid('c48241d7-6a20-41ee-8e4f-70c1729fcca1')
+ g.dashboard.withVariables([
  variables.datasource,
  variables.host,
  variables.cpu,
  variables.disk,
  variables.interface,
  variables.mountpoint,
])
+ g.dashboard.withTags(['telegraf'])
+ g.dashboard.graphTooltip.withSharedCrosshair()
+ g.dashboard.withPanels(
  panels.normalize(
    [
      g.panel.row.new('Overview')
      + g.panel.row.withPanels([
        panels.timeSeries.base('Processes', [
          { target: queries.hostMetric('processes_total', 'total'), capacityLine: true },
          { target: queries.hostMetric('processes_total_threads', 'total_threads', 'total threads'), color: 'white' },
          { target: queries.hostMetric('processes_sleeping', 'sleeping'), color: 'blue' },
          { target: queries.hostMetric('processes_running', 'running'), color: 'red' },
          { target: queries.hostMetric('processes_zombies', 'zombies'), color: 'brown' },
          { target: queries.hostMetric('processes_paging', 'paging'), color: 'orange' },
          { target: queries.hostMetric('processes_stopped', 'stopped'), color: 'yellow' },
          { target: queries.hostMetric('processes_blocked', 'blocked'), color: 'dark-orange' },
          { target: queries.hostMetric('processes_idle', 'idle'), color: 'light-green' },
        ], { h: 7, w: 5 }),

        panels.timeSeries.base('Process forks', [
          { target: queries.hostRateMetric('kernel_processes_forked', 'processes'), color: 'green' },
        ], { h: 7, w: 5, y: 7 }, options={ showLegend: false }),

        panels.timeSeries.base('Interrupts', [
          { target: queries.hostRateMetric('kernel_interrupts', 'interrupts'), color: 'green' },
        ], { h: 7, w: 5, y: 14 }, options={ showLegend: false }),

        panels.timeSeries.mem('Memory', [
          { target: queries.hostMetric('mem_total', 'total'), capacityLine: true },
          { target: queries.hostMetric('mem_used', 'used'), color: 'red' },
          { target: queries.hostMetric('mem_free', 'free'), color: 'blue' },
          { target: queries.hostMetric('mem_buffered', 'buffered'), color: 'yellow' },
          { target: queries.hostMetric('mem_cached', 'cached'), color: 'dark-orange' },
          { target: queries.hostMetric('mem_sunreclaim', 'unrecl', 'slab unrecl'), color: 'purple' },
          { target: queries.hostMetric('mem_sreclaimable', 'recl', 'slab recl'), color: 'super-light-purple' },
          { target: queries.hostMetric('mem_available', 'available'), availableResource: true },
        ], { h: 16, w: 7, x: 5 }),

        panels.timeSeries.mem('Swap', [
          { target: queries.hostMetric('swap_total', 'total'), capacityLine: true },
          { target: queries.hostMetric('swap_free', 'free'), availableResource: true },

        ], { h: 5, w: 7, x: 5, y: 16 }),

        panels.timeSeries.load('Load', [
          { target: queries.hostMetric('system_load1', 'load1', '1 min'), color: 'dark-orange' },
          { target: queries.hostMetric('system_load5', 'load5', '5 min'), color: 'orange' },
          { target: queries.hostMetric('system_load15', 'load15', '15 min'), color: 'super-light-yellow' },
          { target: queries.hostMetric('system_n_cpus', 'cpus'), capacityLine: true },
        ], { h: 5, w: 7, x: 12 }),

        panels.timeSeries.cpuUsage('CPU total', [
          { target: queries.cpuUsage('idle', cpu='cpu-total'), availableResource: true },
          { target: queries.cpuUsage('irq', cpu='cpu-total'), color: 'yellow' },
          { target: queries.cpuUsage('softirq', cpu='cpu-total'), color: 'light-blue' },
          { target: queries.cpuUsage('iowait', cpu='cpu-total'), color: 'super-light-red' },
          { target: queries.cpuUsage('steal', cpu='cpu-total'), color: 'red' },
          { target: queries.cpuUsage('nice', cpu='cpu-total'), color: 'blue' },
          { target: queries.cpuUsage('system', cpu='cpu-total'), color: 'dark-red' },
          { target: queries.cpuUsage('user', cpu='cpu-total'), color: 'dark-orange' },
          { target: queries.cpuUsage('guest', cpu='cpu-total'), color: 'purple' },
          { target: queries.cpuUsage('guest_nice', 'guest nice', cpu='cpu-total'), color: 'super-light-purple' },
        ], { h: 11, w: 7, x: 12, y: 6 }),

        panels.timeSeries.base('Swap IO', [
          { target: queries.hostRateMetric('swap_in', 'in'), color: 'green' },
          { target: queries.hostRateMetric('swap_out', 'out'), color: 'yellow' },
        ], { h: 5, w: 7, x: 12, y: 17 }),

        panels.stat.uptime('Uptime', [
          { target: queries.uptime('uptime') },
        ], { h: 5, w: 5, x: 19 }),

        panels.table.diskUsageSummary('Filesystem', [
          { target: queries.diskUsagePercentInstant('usage') },
        ], { h: 16, w: 5, x: 19, y: 5 }),

      ]),

      g.panel.row.new('Network')
      + g.panel.row.withCollapsed(true)
      + g.panel.row.withPanels([
        panels.timeSeries.networkTraffic('Inbound traffic', [
          { target: queries.networkRateMetric('bytes_recv') },
        ], { h: 8, w: 12 }),
        panels.timeSeries.networkPackets('Inbound packets', [
          { target: queries.networkRateMetric('packets_recv') },
        ], { h: 8, w: 12, y: 8 }),
        panels.timeSeries.networkPackets('Inbound packets dropped', [
          { target: queries.networkRateMetric('drop_in') },
        ], { h: 8, w: 12, y: 16 }),
        panels.timeSeries.networkPackets('Inbound errors', [
          { target: queries.networkRateMetric('err_in') },
        ], { h: 8, w: 12, y: 24 }),
        panels.timeSeries.networkTraffic('Outbound traffic', [
          { target: queries.networkRateMetric('bytes_sent') },
        ], { h: 8, w: 12, x: 12 }),
        panels.timeSeries.networkPackets('Outbound packets', [
          { target: queries.networkRateMetric('packets_sent') },
        ], { h: 8, w: 12, x: 12, y: 8 }),
        panels.timeSeries.networkPackets('Outbound packets dropped', [
          { target: queries.networkRateMetric('drop_out') },
        ], { h: 8, w: 12, x: 12, y: 16 }),
        panels.timeSeries.networkPackets('Outbound errors', [
          { target: queries.networkRateMetric('err_out') },
        ], { h: 8, w: 12, x: 12, y: 24 }),
      ]),

      g.panel.row.new('Disk IO')
      + g.panel.row.withCollapsed(true)
      + g.panel.row.withPanels([
        panels.timeSeries.base('Average queue depth', [
          { target: queries.diskQueueDepth('queue_depth') },
        ], { h: 8, w: 24 }),
        panels.timeSeries.diskIops('Completed read IOPs', [
          { target: queries.diskIops('read') },
        ], { h: 8, w: 12, y: 8 }),
        panels.timeSeries.diskLatency('Read latency', [
          { target: queries.diskLatency('read') },
        ], { h: 8, w: 12, y: 16 }),
        panels.timeSeries.diskThroughput('Read throughput', [
          { target: queries.diskThroughput('read') },
        ], { h: 8, w: 12, y: 24 }),
        panels.timeSeries.diskIops('Completed write IOPs', [
          { target: queries.diskIops('write') },
        ], { h: 8, w: 12, x: 12, y: 8 }),
        panels.timeSeries.diskLatency('Write latency', [
          { target: queries.diskLatency('write') },
        ], { h: 8, w: 12, x: 12, y: 16 }),
        panels.timeSeries.diskThroughput('Write throughput', [
          { target: queries.diskThroughput('write') },
        ], { h: 8, w: 12, x: 12, y: 24 }),
      ]),

      g.panel.row.new('Detailed CPU')
      + g.panel.row.withCollapsed(true)
      + g.panel.row.withPanels([
        panels.timeSeries.cpuUsage('CPU $%s' % variables.cpu.name, [
          { target: queries.cpuUsage('idle'), availableResource: true },
          { target: queries.cpuUsage('irq'), color: 'yellow' },
          { target: queries.cpuUsage('softirq'), color: 'light-blue' },
          { target: queries.cpuUsage('iowait'), color: 'super-light-red' },
          { target: queries.cpuUsage('steal'), color: 'red' },
          { target: queries.cpuUsage('nice'), color: 'blue' },
          { target: queries.cpuUsage('system'), color: 'dark-red' },
          { target: queries.cpuUsage('user'), color: 'dark-orange' },
          { target: queries.cpuUsage('guest'), color: 'purple' },
          { target: queries.cpuUsage('guest_nice', 'guest nice'), color: 'super-light-purple' },
        ], { h: 8 }, options={ repeatField: variables.cpu.name }),
      ]),

      g.panel.row.new('Detailed filesystem')
      + g.panel.row.withCollapsed(true)
      + g.panel.row.withPanels([
        panels.timeSeries.diskUsage('$%s' % variables.mountpoint.name, [
          { target: queries.diskUsage('free'), availableResource: true },
          { target: queries.diskUsage('total'), capacityLine: true },
          { target: queries.diskUsage('used'), color: 'red' },
        ], { h: 8 }, options={ repeatField: variables.mountpoint.name }),
      ]),
    ]
  )
)
