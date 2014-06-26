var page = require('webpage').create(),
    system = require('system'),
    address, output, size;

if (system.args.length < 3 || system.args.length > 5) {
    console.log('Usage: rasterize.js URL filename.pdf [paperwidth*paperheight|paperformat] [zoom]');
    console.log('Usage: rasterize.js URL filename.png [1024x768] [zoom]');
    console.log('  paper (pdf output) examples: "5inx7.5in", "10cmx20cm", "A4", "Letter"');
    phantom.exit(1);
} else {
    address = system.args[1];
    output = system.args[2];

    if (system.args.length > 3 && system.args[2].substr(-4) !== ".pdf") {
        size = system.args[3].split('x');
        page.viewportSize =  { width: size[0], height: size[1] };
    } else {
        page.viewportSize = { width: 1024, height: 768 };
    }

    if (system.args.length > 3 && system.args[2].substr(-4) === ".pdf") {
        size = system.args[3].split('x');
        page.paperSize = size.length === 2 ? { width: size[0], height: size[1], margin: '0px' }
                                           : { format: system.args[3], orientation: 'portrait', margin: '1cm' };
    }
    if (system.args.length > 4) {
        page.zoomFactor = system.args[4];
    }
    page.open(address, function (status) {
        if (status !== 'success') {
            console.log('Unable to load the address!');
        } else {
            window.setTimeout(function () {
                page.render(output);
                phantom.exit();
            }, 200);
        }
    });
}