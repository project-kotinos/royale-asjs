////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////
package org.apache.flex.html.beads
{
	import org.apache.flex.collections.ArrayList;
	import org.apache.flex.core.IBead;
	import org.apache.flex.core.IDragInitiator;
	import org.apache.flex.core.IDataProviderModel;
	import org.apache.flex.core.IItemRenderer;
	import org.apache.flex.core.IItemRendererParent;
	import org.apache.flex.core.IParent;
	import org.apache.flex.core.IStrand;
	import org.apache.flex.core.UIBase;
	import org.apache.flex.events.DragEvent;
	import org.apache.flex.events.EventDispatcher;
	import org.apache.flex.events.IEventDispatcher;
	import org.apache.flex.geom.Point;
	import org.apache.flex.geom.Rectangle;
	import org.apache.flex.html.Group;
	import org.apache.flex.html.Label;
	import org.apache.flex.html.beads.controllers.DragMouseController;
	import org.apache.flex.utils.PointUtils;
	
    
	/**
	 *  The SingleSelectionDragSourceBead brings drag capability to single-selection List components.
	 *  By adding this bead, a user can drag a row of the List to a new location within the list. This bead
	 *  should be used in conjunction with SingleSelectionDropTargetBead.
	 * 
     *  @flexjsignoreimport org.apache.flex.core.IDragInitiator
	 *  @see org.apache.flex.html.beads.SingleSelectionDropTargetBead.
     *
	 *  @langversion 3.0
	 *  @playerversion Flash 10.2
	 *  @playerversion AIR 2.6
	 *  @productversion FlexJS 0.0
	 */
	public class SingleSelectionDragSourceBead extends EventDispatcher implements IBead, IDragInitiator
	{
		public function SingleSelectionDragSourceBead()
		{
			super();
		}
		
		private var _strand:IStrand;
		private var _dragController:DragMouseController;
		
		private var _itemRendererParent:IParent;
		public function get itemRendererParent():IParent
		{
			if (_itemRendererParent == null) {
				_itemRendererParent = _strand.getBeadByType(IItemRendererParent) as IParent;
			}
			return _itemRendererParent;
		}
		
		private var _dragType:String = "move";
		public function get dragType():String
		{
			return _dragType;
		}
		public function set dragType(value:String):void
		{
			_dragType = value;
		}
		
		public function set strand(value:IStrand):void
		{
			_strand = value;
			
			_dragController = new DragMouseController();
			_strand.addBead(_dragController);
			
			IEventDispatcher(_strand).addEventListener(DragEvent.DRAG_START, handleDragStart);
		}
		
		public function get strand():IStrand
		{
			return _strand;
		}
		
		private var indexOfDragSource:int = -1;
		
		private function handleDragStart(event:DragEvent):void
		{
			trace("SingleSelectionDragSourceBead received the DragStart");
			
			if (DragMouseController.dragStartObject == null) return; // not interested in empty things
			
			var startHere:Object = DragMouseController.dragStartObject;
			while( !(startHere is IItemRenderer) && startHere != null) {
				startHere = startHere.parent;
			}
			
			if (startHere is IItemRenderer) {
				var ir:IItemRenderer = startHere as IItemRenderer;
				
				var p:UIBase = (ir as UIBase).parent as UIBase;
				indexOfDragSource = p.getElementIndex(ir);
				
				var dragImage:UIBase = new Group();
				dragImage.className = "DragImage";
				dragImage.width = (ir as UIBase).width;
				dragImage.height = (ir as UIBase).height;
				var label:Label = new Label();
				label.text = ir.data.toString();
				dragImage.addElement(label);
				
				DragEvent.dragSource = ir.data;
				DragEvent.dragInitiator = this;
				DragMouseController.dragImage = dragImage;
			}
		}
		
		/* IDragInitiator */
		
		public function acceptingDrop(dropTarget:Object, type:String):void
		{
			trace("Accepting drop of type "+type);
			if (dragType == "copy") return;
			
			var dataProviderModel:IDataProviderModel = _strand.getBeadByType(IDataProviderModel) as IDataProviderModel;
			if (dataProviderModel.dataProvider is Array) {
				var dataArray:Array = dataProviderModel.dataProvider as Array;
				
				// remove the item being selected
				dataArray.splice(indexOfDragSource,1);
				
				// refresh the dataProvider model
				var newArray:Array = dataArray.slice()
				dataProviderModel.dataProvider = newArray;
			}
			else if (dataProviderModel.dataProvider is ArrayList) {
				var dataList:ArrayList = dataProviderModel.dataProvider as ArrayList;
				
				// remove the item being selected
				dataList.removeItemAt(indexOfDragSource);
				
				// refresh the dataProvider model
				var newList:ArrayList = new ArrayList(dataList.source);
				dataProviderModel.dataProvider = newList;
			}
		}
		
		public function acceptedDrop(dropTarget:Object, type:String):void
		{
			trace("Accepted drop of type "+type);
			var value:Object = DragEvent.dragSource;
			trace(" -- index: "+indexOfDragSource+" of data: "+value.toString());
			
			indexOfDragSource = -1;
		}
		
	}
}
