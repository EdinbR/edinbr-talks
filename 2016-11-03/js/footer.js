/* Page numbers */
var baseline = 28;
var os = baseline;
var ram = baseline + 1;
var byte = baseline + 4;
var chip = baseline + 6;
var io = baseline + 7;

var N = 40; /* A number larger than the number of slides */

/* Count number of clicks */
var events = new Array(N+1).join('0').split('').map(parseFloat);
var curSlide = -1;

window.setInterval(function() {
    if (curSlide != window.slidedeck.curSlide_) {
        curSlide = window.slidedeck.curSlide_;
        if (curSlide == os){ /* Start of OS block*/
            if(events[os] == 0) {
                events[os]=1;
                bars(empty1, 200, "os");
                window.slidedeck.curSlide_= os-1;
            } else if (events[os]==1) {
                window.slidedeck.curSlide_= os-1;
                bars(data1, 60, "os");
                add_images(40, "os");
                events[os] = events[os] + 1;
            } else if (events[os]==2) {
                window.slidedeck.curSlide_= os-1;
                bars(data2, 40,"os");
                events[os] = events[os] + 1;
            } else if (events[os]==3) {
                bars(data3, 40,"os");
                events[os] = events[os] + 1;
            }
        } else if(curSlide == ram) { /* Start of RAM block */
                bars(ram_data, 40, "ram");
                add_ram_text(40);
        } else if(curSlide == byte) { /* Start of byte block */
             if (events[byte]==0) {
                xScale = d3.scale.linear()
                    .domain([0, 4])
                    .range([0, w]);
                events[byte]=  1;
                window.slidedeck.curSlide_= byte-1;
                bars(byte_os, 60, "byte");
                add_images(40, "byte");
            } else if (events[byte]==1) {
                bars(byte_full, 40,"byte");
            }
        } else if(curSlide == chip) { /* Start of Chip block */
          if (events[chip]==0) {
                xScale = d3.scale.linear()
                    .domain([0, 9])
                    .range([0, w]);
                events[chip]=1;
                window.slidedeck.curSlide_= chip-1;
                bars(chip_partial, 60, "chip");
                add_chip_text(60);
            } else if (events[chip]==1) {
                bars(chip_full, 40, "chip");
                events[os] = events[os] + 1;
            }
        } else if(curSlide == io) { /* Start of IO block */
            if(events[io]==0) {
               window.slidedeck.curSlide_= io-1;
               events[io]=1;
            } else if (events[io]==1) {
                window.slidedeck.curSlide_= io-1;
                events[io] = 2;
                update_scatter(read5, "#sch_scatter1", "Reading: 5MB");
                update_scatter(write5, "#sch_scatter2", "Writing: 5MB");
            } else if (events[io]==2) {
                window.slidedeck.curSlide_= io-1;
                events[io] = 3;
                sch_xScale = d3.scale.linear()
                  .domain([1, 14])
                  .range([sch_pad_side, sch_w-sch_pad_ep]);
                update_scatter(read50, "#sch_scatter1", "Reading: 50MB");
                update_scatter(write50, "#sch_scatter2", "Writing: 50MB");
            } else if (events[io]==3) {
                events[io] = 4;
                sch_xScale = d3.scale.linear()
                  .domain([1, 12])
                  .range([sch_pad_side, sch_w-sch_pad_ep]);
                update_scatter(read200, "#sch_scatter1", "Reading: 200MB");
                update_scatter(write200, "#sch_scatter2", "Writing: 200MB");
            }
        }
    }
}, 100);
