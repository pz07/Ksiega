function createCategoryPanel(submitCatFunction){
	//zdarzenia formularza
	var handleSubmit = function() {
		submitCatFunction(this.getData().categoryId, this.getData().categoryName)
		this.hide();
	};
	var handleCancel = function() {
		this.hide();
	};
	
	// Utworzenie dialogu
	var catDialog = new YAHOO.widget.Dialog("catDialogDiv", 
							{ width : "30em",
							  fixedcenter : true,
							  visible : false, 
							  constraintoviewport : true,
							  buttons : [ { text:"Submit", handler:handleSubmit, isDefault:true },
								      	  { text:"Cancel", handler:handleCancel } ]
							});
	catDialog.render();

	//Utworzenie drzewa
	var tree;
    var selectedNode = null;

    function loadNodeData(node, fnLoadComplete)  {
	   var sUrl = "/ajax/getSubCategories?parentCatId=" + node.data.id; 
	     
	    var callback = { 
	        success: function(oResponse) { 
				result = oResponse.responseText;
				
				categories = result.split("|");
				for(var i = 0; i < categories.length; i++){
					catDef = categories[i].split(":");
					if(catDef.length == 3){
						var tempNode = new YAHOO.widget.TextNode({id: catDef[0], label: catDef[1]}, node, false); 	
						if(isNaN(catDef[2]) || Number(catDef[2]) == 0 ){
							tempNode.isLeaf = true;
						}
					}
				}
	            oResponse.argument.fnLoadComplete(); 
	        }, 
	        failure: function(oResponse) { 
	            alert('błąd (Zrobić coś z tym!)!!!!!!!!');
	            oResponse.argument.fnLoadComplete(); 
	        }, 
	        argument: { 
	            "node": node, 
	            "fnLoadComplete": fnLoadComplete 
	        }, 
	        timeout: 1000 
	    }; 
	     
	    YAHOO.util.Connect.asyncRequest('GET', sUrl, callback); 
     }
	 
	 tree = new YAHOO.widget.TreeView("catTreeDiv");
	 tree.setDynamicLoad(loadNodeData, 0);
	    
	 var root = tree.getRoot();
	    
 	 var tempNode = new YAHOO.widget.TextNode({id: 0, label: "Kategorie"}, root, false);
	 tempNode.isLeaf = false;
	 
	 tempNode.expand();
	 
	 tree.subscribe("labelClick", function(node) { 
    	  if(selectedNode != null && selectedNode.data.id == node.data.id){
		  	 selectedNode = null; 
			 node.labelStyle = "ygtvlabel";
			 
			 catDialog.form.categoryName.value = "";
			 catDialog.form.categoryId.value = "";
		  }
		  else{
		  	if(selectedNode != null){
			 	selectedNode.labelStyle = "ygtvlabel";
			}
			
			node.labelStyle = 'checkedLabel';
    	  	selectedNode = node;

			catDialog.form.categoryId.value = node.data.id;
			catDialog.form.categoryName.value = node.data.label;

		  }
   	 	  node.tree.draw();
 	 }); 
	    
	 tree.draw();
	 
	 return [catDialog, tree];
}

