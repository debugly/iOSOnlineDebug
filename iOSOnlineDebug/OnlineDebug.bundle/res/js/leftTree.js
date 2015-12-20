
function LeftTree(options){
    
    var o = options;
    var dom = $('<div id="zTreeDivStyle"><ul id="treeDemo" class="ztree"></ul></div>');
    o.parentDom.append(dom);
    // util
    function hasVisiableNode(treeNode){
        
        if (treeNode.children && (treeNode.children.length > 0)) {
            for (var i = 0; i < treeNode.children.length; i++) {
                if (!treeNode.children[i].isHidden) {
                    return true;
                };
            };
        };
        return false;
    };
    
    function onAsyncError(event, treeId, treeNode, XMLHttpRequest, textStatus, errorThrown) {
        alert('错误，请刷新页面');
    };
    
    function onAsyncSuccess(event, treeId, treeNode, msg) {
        
    };
    
    function canExpandNode(treeNode){
        if (treeNode.isFile) {
            return true;
        };
        return hasVisiableNode(treeNode);
    }
    
    function onDblClick(treeId, treeNode) {
        return canExpandNode(treeNode);
    };
    
    function beforeClick(treeId, treeNode, clickFlag) {
//        alert("bool"+ treeNode.isFile);
        return !(!treeNode.isFile);
    };
    
    function downFile(path) {
//        window.open(
//                    path,
//                    '_blank' // <- This is what makes it open in a new window.
//                    );
//        location.href = ;
        window.href = path;
    }
    
    function loadsSandboxResource (filePath) {
        $.get('/sandboxResource?path='+filePath, function(data) {
                  alert("succ");
                  });
    }
    
    function onClick(event, treeId, treeNode) {
//        loadsSandboxResource(treeNode.path);
        if(treeNode.isFile){
            downFile(treeNode.path);
        }
    };
    
    function beforeExpand(treeId, treeNode) {
        var canExpand = canExpandNode(treeNode);
        if (canExpand) {
            return true;
        }else{
            loadNode(treeNode);
        }
        return false;
    };
    function doFilter(nodes){
        
        $.each(nodes,function(index,entity){
               if (!entity.isFile) {
               var children = [{isHidden:true}];
               entity["children"] = children;
               };
               });
        return nodes;
    };
    
    function filter(treeId, parentNode, childNodes) {
        
        if (!childNodes || childNodes.length == 0){return null};
        return doFilter(childNodes);
    }
    
    var setting = {
        // view: {
        // 	dblClickExpand: dblClickExpand
        // },
    data: {
    key: {
    title:"t"
    }
    },
    callback: {
    beforeExpand: beforeExpand,
    beforeClick:beforeClick,
    onClick: onClick,
    onAsyncError: onAsyncError,
    onAsyncSuccess: onAsyncSuccess
    },
    async: {
				enable: true,
				url:"/sandboxDirectory",
				type: "get",
				autoParam:["path"],
				dataFilter: filter
    }
    }
    
    
    var init = function (options) {
        $.fn.zTree.init($("#treeDemo"), setting, null);
    }
    
    function zTree () {
        // body...
        return $.fn.zTree.getZTreeObj("treeDemo");
    }
    
    var loadRootNode = function () {
        $.getJSON('/sandboxDeviceName', function(dic) {
                  var text = dic["device"];
                  var root = [{"name":text,"path":"/","isFile":false}];
                  doFilter(root);
                  zTree().addNodes(null,-1,root,true);
                  //              var rootNode = zTree().getNodes()[0];
                  });
        //        zTree().reAsyncChildNodes(rootNode,'refresh',false);
    }
    
    var loadNode = function (treeNode) {
        if (treeNode) {
            zTree().reAsyncChildNodes(treeNode,'refresh',false);
        };
    }
    
    return {
    init: init,
    loadRootNode: loadRootNode,
    loadNode: loadNode,
    wrapper: dom
    };
    
}