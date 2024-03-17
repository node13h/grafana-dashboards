local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';

local overrides = import './overrides.libsonnet';

// All units: https://github.com/grafana/grafana/blob/main/packages/grafana-data/src/valueFormats/categories.ts

{
  // This function assumes panels within each row have correct gridPos set already.
  lineUpRows(rows):
    std.foldl(
      function(acc, row)
        acc {
          local rowH = std.get(row.gridPos, 'h', 1),
          local rowY = std.get(row.gridPos, 'y', 0),

          local top = super.bottom,
          local bottom = rowH + std.foldl(
            function(lowestPoint, panel)
              std.max(panel.gridPos.y + panel.gridPos.h, lowestPoint),
            row.panels,
            0,
          ),

          rows+: [
            row {
              gridPos+: {
                y: top,
              },
              panels: std.map(
                function(panel)
                  panel {
                    gridPos+: {
                      y+: top + rowH,
                    },
                  },
                row.panels
              ),
            },
          ],

          bottom+: bottom,
        },
      rows,
      {
        rows: [],
        bottom: 0,
      }
    ).rows,

  normalize(rows):
    g.util.panel.resolveCollapsedFlagOnRows(
      self.lineUpRows(rows)
    ),

  splitFields(fields):
    std.foldl(
      function(acc, field)
        acc {
          overrides+:
            (if std.get(field, 'availableResource', false)
             then [overrides.timeSeries.availableResource(field.target.refId)]
             else [])
            + (if std.get(field, 'capacityLine', false)
               then [overrides.timeSeries.capacityLine(field.target.refId)]
               else [])
            + (if 'color' in field
               then [overrides.timeSeries.colored(field.target.refId, field.color)]
               else []),
          targets+: [field.target],
        },
      fields,
      { targets: [], overrides: [] }
    ),

  stat: {
    local stat = g.panel.stat,

    base(title, fields, gridPos, options={}):
      local f = $.splitFields(fields);

      stat.new(title)
      + stat.queryOptions.withTargets(f.targets)
      + stat.panelOptions.withGridPos(
        h=std.get(gridPos, 'h', 8),
        w=std.get(gridPos, 'w', 8),
        x=std.get(gridPos, 'x', 0),
        y=std.get(gridPos, 'y', 0)
      ),

    uptime(title, fields, gridPos, options={}):
      self.base(title, fields, gridPos, options=options)
      + stat.standardOptions.color.withMode('thresholds')
      + stat.standardOptions.thresholds.withMode('absolute')
      + stat.standardOptions.thresholds.withSteps(
        [
          { color: 'green', value: null },
          { color: 'yellow', value: 7884000 },
          { color: 'red', value: 15768000 },
        ]
      )
      + stat.standardOptions.withUnit('dtdurations'),

  },

  table: {
    local table = g.panel.table,

    base(title, fields, gridPos, options={}):
      local f = $.splitFields(fields);
      local filterable = std.get(options, 'filterable', false);

      table.new(title)
      + table.queryOptions.withTargets(f.targets)
      + table.fieldConfig.defaults.custom.withFilterable(filterable)
      + table.panelOptions.withGridPos(
        h=std.get(gridPos, 'h', 8),
        w=std.get(gridPos, 'w', 8),
        x=std.get(gridPos, 'x', 0),
        y=std.get(gridPos, 'y', 0)
      ),

    diskUsageSummary(title, fields, gridPos, options={}):
      self.base(title, fields, gridPos, options)
      + table.standardOptions.color.withMode('thresholds')
      + table.standardOptions.thresholds.withMode('absolute')
      + table.standardOptions.thresholds.withSteps(
        [
          { color: 'super-light-green', value: null },
          { color: 'semi-dark-red', value: 90 },
        ]
      )
      + table.queryOptions.withTransformations([
        table.queryOptions.transformation.withId('organize')
        + table.queryOptions.transformation.withOptions(
          {
            excludeByName: { Time: true },
            renameByName: { Value: 'Used', path: 'Mounted on' },
          }
        ),
      ])
      + table.standardOptions.withOverrides([
        overrides.table.gauge('Used'),
      ])
      + table.standardOptions.withMin(0)
      + table.standardOptions.withMax(100)
      + table.standardOptions.withUnit('percent'),
  },

  timeSeries: {
    local timeSeries = g.panel.timeSeries,

    base(title, fields, gridPos, options={}):
      local f = $.splitFields(fields);
      local minValue = std.get(options, 'minValue', 0);
      local showLegend = std.get(options, 'showLegend', true);

      timeSeries.new(title)
      + timeSeries.queryOptions.withTargets(f.targets)
      + timeSeries.queryOptions.withInterval('30s')
      + timeSeries.options.legend.withDisplayMode('list')
      + timeSeries.options.legend.withShowLegend(showLegend)
      + timeSeries.standardOptions.withMin(minValue)
      + timeSeries.standardOptions.withOverrides(f.overrides)
      + timeSeries.panelOptions.withGridPos(
        h=std.get(gridPos, 'h', 8),
        w=std.get(gridPos, 'w', 8),
        x=std.get(gridPos, 'x', 0),
        y=std.get(gridPos, 'y', 0)
      )
      + if 'repeatField' in options then
        timeSeries.panelOptions.withRepeat(options.repeatField)
      else
        {},

    networkTraffic(title, fields, gridPos, options={}):
      self.base(title, fields, gridPos, options=options)
      + timeSeries.standardOptions.withUnit('bps'),

    networkPackets(title, fields, gridPos, options={}):
      self.base(title, fields, gridPos, options=options)
      + timeSeries.standardOptions.withUnit('pps'),

    diskIops(title, fields, gridPos, options={}):
      self.base(title, fields, gridPos, options=options)
      + timeSeries.standardOptions.withUnit('iops')
      + timeSeries.options.legend.withPlacement('right'),

    diskLatency(title, fields, gridPos, options={}):
      self.base(title, fields, gridPos, options=options)
      + timeSeries.standardOptions.withUnit('ms')
      + timeSeries.options.legend.withPlacement('right'),

    diskThroughput(title, fields, gridPos, options={}):
      self.base(title, fields, gridPos, options=options)
      + timeSeries.standardOptions.withUnit('binBps')
      + timeSeries.options.legend.withPlacement('right'),

    cpuUsage(title, fields, gridPos, options={}):
      self.base(title, fields, gridPos, options=options)
      + timeSeries.standardOptions.withUnit('percent')
      + timeSeries.standardOptions.withMax(100),

    diskUsage(title, fields, gridPos, options={}):
      self.base(title, fields, gridPos, options=options)
      + timeSeries.standardOptions.withUnit('decbytes'),

    mem(title, fields, gridPos, options={}):
      self.base(title, fields, gridPos, options=options)
      + timeSeries.standardOptions.withUnit('bytes'),

    load(title, fields, gridPos, options={}):
      self.base(title, fields, gridPos, options=options)
      + timeSeries.fieldConfig.defaults.custom.withDrawStyle('bars')
      + timeSeries.options.legend.withShowLegend(false),
  },
}
