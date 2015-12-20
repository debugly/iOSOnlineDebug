function Navbar(options) {
    
    var o = options;
    
    var dom = $('<div class="navbar"></div>');
    var title = $('<div class="navbar_title"></div>');
    var back  = $('<a class="navbar_back"></a>');
    var loading = $('<div class="navbar_loading">Loading....</div>');
    
    dom.append(title);
    dom.append(back);
    dom.append(loading);
    o.parentDom.append(dom);
    
    var showLoadingFunc = function() { loading.show(); }
    var hideLoadingFunc = function() { loading.hide(); }
    
    var versionFunc = function(ver) {
        title.text( ver );
    };
    
    var backFunc = function(ver,target){
        back.text(ver);
        back.attr("href", "/");
    };
    
    hideLoadingFunc();
    
    return {
        domElement: dom,
        version: versionFunc,
        back:backFunc,
        showLoading: showLoadingFunc,
        hideLoading: hideLoadingFunc
    };
}
