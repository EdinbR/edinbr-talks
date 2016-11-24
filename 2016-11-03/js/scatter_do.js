
//Width and height
var sch_w = 350;
var sch_h = 350;
var sch_pad_side = 60;
var sch_pad_ep = 10;
var sch_pad_top = 60;


var sch_xScale = d3
    .scale
    .linear()
    .domain([1, 15])
    .range([sch_pad_side, sch_w-sch_pad_ep]);

var sch_yScale = d3
    .scale.linear()
    .domain([1, 5])
    .range([sch_h - sch_pad_top, sch_pad_top]);


var sch_xAxis = d3.svg.axis()
    .scale(sch_xScale)
    .orient("bottom")
    .outerTickSize(0)
    .ticks(5);

var sch_yAxis = d3
  .svg.axis()
  .scale(sch_yScale)
  .orient("left")
  .innerTickSize(-(sch_w-sch_pad_side-sch_pad_ep))
    .outerTickSize(0)
    .ticks(10)
  .tickPadding(10);

initalise_scatter(read0, "#sch_scatter1");
initalise_scatter(write0, "#sch_scatter2");


/*update_scatter(read50, "#sch_scatter1", "Reading: 50MB");
update_scatter(write50, "#sch_scatter2", "Writing: 50MB");
sch_xScale = d3.scale.linear()
    .domain([1, 12])
     .range([sch_pad_side, sch_w-sch_pad_ep]);

 update_scatter(read200, "#sch_scatter1", "Reading: 500MB");
update_scatter(write200, "#sch_scatter2", "Writing: 500MB");


*/
