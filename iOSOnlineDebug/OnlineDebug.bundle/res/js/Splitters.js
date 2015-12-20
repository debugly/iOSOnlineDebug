function Splitters(options) {
    var o = options;
    
    var leftDom = $('<div class="splitter"></div>');
    leftDom.css('left', o.centerColumn.css('left'));
    leftDom.css('margin-left', '-7px');
    
    o.parentDom.append(leftDom);
    
    leftDom.mousedown(function(e) {
                      var lastX = e.pageX;
                      
                      var handleMoveFunc = function(ee) {
                      var dx = lastX - ee.pageX;
                      lastX = ee.pageX;
                      var newWidth = (parseInt(o.leftColumn.css('width')) - dx);
                      if ( newWidth > 50 ) {
                      leftDom.css('left', (parseInt(leftDom.css('left')) - dx)+'px');
                      o.leftColumn.css('width', newWidth+'px');
                      o.centerColumn.css('left', (parseInt(o.centerColumn.css('left')) - dx)+'px');
                      }
                      }
                      
                      var handleMouseUp = function() {
                      $(window).unbind('mouseup', handleMouseUp);
                      $(window).unbind('mousemove', handleMoveFunc);
                      };
                      
                      $(window).bind('mousemove', handleMoveFunc);
                      $(window).bind('mouseup', handleMouseUp);
                      });
    
    if(o.rightColumn){
        var rightDom = $('<div class="splitter"></div>');
        rightDom.css('right', o.centerColumn.css('right'));
        rightDom.css('margin-right', '-7px');
        
        o.parentDom.append(rightDom);
        
        rightDom.mousedown(function(e) {
                           var lastX = e.pageX;
                           
                           var handleMoveFunc = function(ee) {
                           var dx = lastX - ee.pageX;
                           lastX = ee.pageX;
                           var newWidth = parseInt(o.rightColumn.css('width')) + dx;
                           if ( newWidth > 50 ) {
                           rightDom.css('right', (parseInt(rightDom.css('right')) + dx)+'px');
                           o.rightColumn.css('width', newWidth+'px');
                           o.centerColumn.css('right', (parseInt(o.centerColumn.css('right')) + dx)+'px');
                           }
                           }
                           
                           var handleMouseUp = function() {
                           $(window).unbind('mouseup', handleMouseUp);
                           $(window).unbind('mousemove', handleMoveFunc);
                           };
                           
                           $(window).bind('mousemove', handleMoveFunc);
                           $(window).bind('mouseup', handleMouseUp);
                           });
    }
    return {};
}
