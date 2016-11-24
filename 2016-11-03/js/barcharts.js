//Simple d3.js barchart example to illustrate d3 selections

//other good related tutorials
//http://www.recursion.org/d3-for-mere-mortals/
//http://mbostock.github.com/d3/tutorial/bar-1.html


var w = 750;
var h = 500;

var os_empty =  [{"x":0,"y":""}, {"x":0,"y":""}, {"x":0,"y":""},
              {"x":0,"y":""}, {"x":0,"y":""}, {"x":0,"y":""},
              {"x":0,"y":""}, {"x":0,"y":""}, {"x":0,"y":""}];

var empty1 =  [{"x":90,"y":"233"}, {"x":0,"y":""}, {"x":0,"y":""},
              {"x":0,"y":""}, {"x":0,"y":""}, {"x":0,"y":""},
              {"x":0,"y":""}, {"x":0,"y":""}, {"x":0,"y":""}];
//OS: Apple, Linux, Windows
var data1 = [{"x":38,"y":"38"}, {"x":0,"y":""},{"x":0,"y":""},
              {"x":89,"y":"89"},{"x":0,"y":""},{"x":0,"y":""},
              {"x":106,"y":"106"}, {"x":0,"y":""}, {"x":0,"y":""}];

var data2 = [
    {"x":30,"y":"30\u00A0\u00A0\u00A0\u00A0\u00A0\u00A0 Std. BLAS"},
    {"x":8,"y":"8"},{"x":0,"y":""},
    {"x":69,"y":"69"},{"x":20,"y":"20\u00A0\u00A0 Opt. BLAS"},{"x":0,"y":""},
    {"x":91,"y":"91"},
    {"x":15,"y":"15"},
    {"x":0,"y":""}];

// No Byte, Byte
var data3 = [{"x":33,"y":"33"}, {"x":4,"y":" 4"},{"x":0,"y":""},
              {"x":65,"y":"65"},{"x":28,"y":"28\u00A0\u00A0\u00A0\u00A0 Byte Compiled"},{"x":0,"y":""},
             {"x":87,"y":"87\u00A0\u00A0\u00A0\u00A0 Standard"}, {"x":3,"y":"3"}, {"x":0,"y":""}];

var os_colours = ["#49412c", "#b0a18e", "white",
              "#49412c", "#b0a18e", "white",
              "#49412c", "#b0a18e"];


var ram_data = [{"x":4, "y":"4"}, {"x":5, "y":"5"}, {"x":37, "y":"37"}, {"x":90, "y":"90"},
          {"x":53, "y":"53"}, {"x":10, "y":"10"}, {"x":4, "y":"4"}, {"x":5, "y":"5"},
          {"x":4, "y":"4"}];

var ram_empty =  [{"x":0,"y":""}, {"x":0,"y":""}, {"x":0,"y":""},
              {"x":0,"y":""}, {"x":0,"y":""}, {"x":0,"y":""},
              {"x":0,"y":""}, {"x":0,"y":""}, {"x":0,"y":""}];

var ram_colours = ["#01afd5", "#01afd5", "#01afd5", "#01afd5", "#01afd5", "#01afd5", "#01afd5", "#01afd5", "#01afd5"];


var byte_empty = os_empty;
var byte_colours = os_colours;
var byte_os = [{"x":1,"y":"1"}, {"x":0,"y":""},{"x":0,"y":""},
              {"x":1,"y":"1"},{"x":0,"y":""},{"x":0,"y":""},
              {"x":1.4,"y":"1.4"}, {"x":0,"y":""}, {"x":0,"y":""}];

var byte_full = [{"x":3.0,"y":"3.0\u00A0\u00A0 Std."}, {"x":1,"y":"1\u00A0\u00A0 Byte Compiled"}, {"x":0,"y":""},
              {"x":3.4,"y":"3.4\u00A0\u00A0 Std."}, {"x":1,"y":"1\u00A0\u00A0 Byte Compiled"}, {"x":0,"y":""},
              {"x":3.9,"y":"3.9\u00A0\u00A0 Std."}, {"x":1,"y":"1\u00A0\u00A0 Byte Compiled"}, {"x":0,"y":""}];

var chip_empty = os_empty;
var chip_colours = os_colours;
var chip_partial = [{"x":1.6,"y":"1.6"}, {"x":0,"y":""},{"x":0,"y":""},
              {"x":1.2,"y":"1.2"},{"x":0,"y":""},{"x":0,"y":""},
              {"x":1,"y":"1"}, {"x":0,"y":""}, {"x":0,"y":""}];

var chip_full = [{"x":8,"y":"8\u00A0\u00A0 Std. BLAS"}, {"x":0,"y":""},{"x":0,"y":""},
              {"x":7,"y":"7\u00A0\u00A0 Std. BLAS"},{"x":1.6,"y":"1.6\u00A0\u00A0 Opt. BLAS"},{"x":0,"y":""},
              {"x":6,"y":"6\u00A0\u00A0 Std. BLAS"}, {"x":1,"y":"1"}, {"x":0,"y":""}];

var max = 110;


var y = d3.scale.ordinal()
    .domain(d3.range(data1.length))
    .rangeBands([0, h], 0.2);

//   var max = d3.max(data, function(d) {    //Returns 480
//      return d.x+5;  //References first value in each sub-array
//    });

var xScale = d3.scale.linear()
      .domain([0, max])
      .range([0, w]);
function bars(data, wid, id)
{
    var vis = d3.select("#" + id + "_barchart");
    var rect_bars = vis.selectAll("rect.bar")
        .data(data);

    /* Update text*/
   d3.select("#" + id + "_barchart").selectAll("text")
        .data(data)
        .transition()
        .duration(1000)
        .ease("quad")
        .attr("x",  function(d, i) { return 10;})// xScale(d.x); })
        .attr("y",  function(d, i) { return wid/2; })
        .attr("font-size", Math.sqrt(wid/40)*17 + "px")
        .attr("transform",function(d,i) {
            return "translate(" + [0, y(i)] + ")";
        })
        .text(function(d) {return d.y;});

    rect_bars.exit()
        .transition()
        .duration(100)
        .ease("exp")
        .attr("width", 0)
        .remove();

    rect_bars
        .attr("stroke-width", 0)
        .transition()
        .duration(1000)
        .ease("quad")
        .attr("width", function(d, i){ return xScale(d.x)})
        .attr("height", wid)
        .attr("transform", function(d,i) {
            return "translate(" + [0, y(i)] + ")";
        });

}

function init(id)
{
    var svg = d3.select("#" + id + "_svg")
        .attr("width", w)
        .attr("height", h);

    svg.append("svg:g")
        .attr("id", id + "_barchart")
        .attr("transform", "translate(70,0)");

  var vis = d3.select("#" + id + "_barchart");
  var bars1 = vis.selectAll("rect.bar")
        .data(eval(id+"_empty"));

  vis.selectAll("rect.bar")
    .data(eval(id + "_colours"))
    .enter()
    .append("svg:rect")
    .attr("class", "bar")
    .attr("fill", function(d, i) {return d;});

    bars1.enter()
        .append("text")
        .attr("y", function(d, i) { return  0; })
        .attr("dy", 10)
        .attr("fill", "white")
        .attr("font-family","sans-serif")
        .attr("font-size", "20px")
        .text(function(d) { return d.y; })
        .attr("transform",function(d,i) {
            return "translate(" + [0, y(i)] + ")";
        });


    bars(eval(id + "_empty"), 40, id);
     //bars(ram_empty, 40, id);
}



function add_images(wid, id) {
  var os = ["resources/apple.jpg","resources/Tux.png", "resources/windows.png"];
  var vis = d3.select("#" + id + "_barchart");
  vis.selectAll("image.bar").data(os).enter().append("svg:image")
    .attr('x',-60)
    .attr('y',function(d, i) {return y(i*3 );})
    .attr('width', 50)
    .attr('height', 50)
    .attr("xlink:href", function(d, i) {return d;});
}

function add_ram_text(wid) {
    var id = "ram";
    var ram_text = ["1GB", "2GB","4GB","8GB","16GB","32GB","64GB","128GB","256GB"];

    var svg = d3.select("#" + id + "_svg")
        .attr("width", w)
        .attr("height", h);

    svg.append("svg:g")
        .attr("id", id + "_text")
        .attr("transform", "translate(70,0)");

    var vis = d3.select("#" + id + "_text");
    var bars1 = vis.selectAll("text.bar")
        .data(ram_text);
    bars1.enter()
        .append("text")
        .attr('x',-60)
        .attr('y',function(d, i) {return wid/2;})
       .attr("fill", "#262216")
        .attr("font-family","sans-serif")
        .attr("font-size", "14px")

        .text(function(d) { return d; })
        .attr("y",  function(d, i) { return wid/2; })
        .attr("transform", function(d,i) {
            return "translate(" + [0, y(i)] + ")";
        });

}

function add_chip_text(wid) {
    var id = "chip";
    var chip_text = ["i3", "", "","i5","","","i7",""];

    var svg = d3.select("#" + id + "_svg")
        .attr("width", w)
        .attr("height", h);

    svg.append("svg:g")
        .attr("id", id + "_text")
        .attr("transform", "translate(70,0)");

    var vis = d3.select("#" + id + "_text");
    var bars1 = vis.selectAll("text.bar")
        .data(chip_text);
    bars1.enter()
        .append("text")
        .attr('x',-60)
        .attr('y',function(d, i) {return wid/2;})
        .text(function(d) { return d; })
        .attr("y",  function(d, i) { return wid/2; })
        .attr("transform", function(d,i) {
            return "translate(" + [0, y(i)] + ")";
        });

}











