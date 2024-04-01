local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';

local panels = import './panels.libsonnet';
local queries = import './queries.libsonnet';
local variables = import './variables.libsonnet';

g.dashboard.new('Telegraf / MD RAID')
+ g.dashboard.withUid('9b3451e5-8440-499a-87d5-ce4c1fc21f3f')
+ g.dashboard.withVariables([
  variables.datasource,
  variables.hostWithMdArrays,
  variables.mdArray,
])
+ g.dashboard.withTags(['telegraf'])
+ g.dashboard.graphTooltip.withSharedCrosshair()
+ g.dashboard.withPanels(
  panels.normalize(
    [
      g.panel.row.new('Summary')
      + g.panel.row.withPanels([
        panels.stat.boolean(
          'All arrays are active',
          'Some arrays are degraded',
          [
            { target: queries.mdAllArraysActive('active') },
          ],
          { h: 2, w: 4 }
        ),
        panels.stat.boolean(
          'All array members are active',
          'Some array members are missing',
          [
            { target: queries.mdAllArrayMembersActive('active') },
          ],
          { h: 2, w: 6, x: 4 }
        ),
        panels.stat.horizontal(
          '',
          [
            { target: queries.mdTotalArrays('total') },
          ],
          { h: 2, w: 4, x: 20 }
        ),
      ]),

      g.panel.row.new('${array}')
      + g.panel.row.withRepeat(variables.mdArray.name)
      + g.panel.row.withPanels([
        panels.timeSeries.base('Members', [
          { target: queries.mdStatelessMetric('DisksTotal', 'total ({{Devices}})'), capacityLine: true },
          { target: queries.mdStatelessMetric('DisksActive', 'active'), color: 'green' },
          { target: queries.mdStatelessMetric('DisksFailed', 'failed'), color: 'red' },
          { target: queries.mdStatelessMetric('DisksSpare', 'spare'), color: 'white' },
          { target: queries.mdStatelessMetric('DisksDown', 'down'), color: 'orange' },
        ], { h: 8, w: 6 }),
        panels.timeSeries.short('Blocks', [
          { target: queries.mdStatelessMetric('BlocksTotal', 'total ({{Devices}})'), capacityLine: true },
          { target: queries.mdMetric('BlocksSynced', 'active/{{ActivityState}}'), color: 'yellow' },
        ], { h: 8, w: 6, x: 6 }),
        panels.stat.name(
          'Array state',
          [
            { target: queries.mdArrayState('state') },
          ],
          { h: 3, w: 3, x: 12 }
        ),
        panels.stat.vertical(
          'Members',
          [
            { target: queries.mdActiveArrayMembers('active', 'Active') },
            { target: queries.mdTotalArrayMembers('total', 'Total') },
          ],
          { h: 5, w: 3, x: 12, y: 3 }
        ),

        panels.stat.numberFailures(
          'Failed members',
          [
            { target: queries.mdFailedArrayMembers('active') },
          ],
          { h: 8, w: 3, x: 15 }
        ),

        panels.stat.minutes(
          'Sync/scan finish time',
          [
            { target: queries.mdSyncFinishTime('time') },
          ],
          { h: 4, w: 3, x: 18 },
        ),

        panels.stat.kibs(
          'Sync/scan speed',
          [
            { target: queries.mdSyncSpeed('speed') },
          ],
          { h: 4, w: 3, x: 18, y: 4 }
        ),

        panels.barGauge.recoveryPercentage(
          'Synced/checked',
          [
            { target: queries.mdBlockSyncedPercentage('checked') },
          ],
          { h: 8, w: 3, x: 21 }
        ),
      ]),
    ]
  )
)
