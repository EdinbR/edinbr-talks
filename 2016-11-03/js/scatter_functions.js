function initalise_scatter (data, id) {
    //Create SVG element
    var svg = d3.select(id);

    //Create circles
    svg.selectAll("circle")
        .data(read0)
        .enter()
        .append("circle")
        .attr("cx", function(d) {
            return sch_xScale(d.x);
        })
        .attr("cy", function(d) {
            return sch_yScale(d.y);
        })
        .attr("r", 1);
    var text_size = "10px";
    //Create X axis
    svg.append("g")
        .attr("class", "x axis")
        .attr("transform", "translate(0," + (sch_h - sch_pad_side) + ")")
        .attr("font-size", text_size)
        .call(sch_xAxis);

    //Create Y axis
    svg.append("g")
        .attr("class", "y axis")
        .attr("transform", "translate(" + sch_pad_top + ",0)")
        .attr("font-size", text_size)
        .call(sch_yAxis);

    d3.select(id)
        .append("text")
        .attr("class", "x label")
                    .attr("text-anchor", "end")
        .attr("x", sch_pad_side + (sch_w-sch_pad_ep-sch_pad_side)/2)
        .attr("y", sch_h -sch_pad_top/2)
        .attr("font-size", "10px")
        .text("Rank");

    d3.select(id)
        .append("text")
        .attr("class", "y label")
        .attr("text-anchor", "end")
        .attr("x", sch_pad_top-180)
        .attr("y", sch_pad_side-30)
        .attr("font-size", "10px")
        .attr("transform", "rotate(-90)")
        .text("Relative timing");

    d3.select(id)
        .append("text")
        .attr("class", "title")
        .attr("x", sch_w-100)
        .attr("y", 50)
        .attr("font-weight", "bold")
        .attr("font-size", "12px")
        .text("");

    var lines = [{"x":1},{"x":2}, {"x":3}, {"x":4}, {"x":5}];
    svg.selectAll("lines")
        .data(lines)
    .enter()
    .append("line")
    .attr("x1", sch_xScale(1))
    .attr("x2", sch_xScale(15))
    // .attr("y1", sch_yScale(2))
    // .attr("y2", sch_yScale(2))
    .attr("y1", function(d) {return sch_yScale(d.x)})
   .attr("y2", function(d) {return sch_yScale(d.x)})
    .style("stroke", "rgb(189, 189, 189)");

}

function update_scatter(data, id, title){

    //Create SVG element
    var svg = d3.select(id);
    sch_yAxis.ticks(5);

    //Update all circles
    svg.selectAll("circle")
	.data(data)
	.transition()
   	.duration(1000)
        .attr("r", 4)
        .attr("fill", "#b0a18e")
	.attr("cx", function(d) {
	    return sch_xScale(d["x"]);
	})
	.attr("cy", function(d) {
	    return sch_yScale(d["y"]);
	});

    svg.selectAll(".x.axis")
        .transition().delay(1000).duration(1000)
        .call(sch_xAxis.scale(sch_xScale));
    svg.selectAll(".y.axis")
        .transition().delay(1000).duration(1000)
        .call(sch_yAxis.scale(sch_yScale));

    svg.select(".x.axis")
	.transition()
	.duration(1000)
	.call(sch_xAxis);

    //Update Y axis
    svg.select(".y.axis")
	.transition()
	.duration(1000)
	.call(sch_yAxis);

    svg.select(".title")
        .transition()
        .duration(1000)
        .text(title);

}











