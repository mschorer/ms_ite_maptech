package de.ms_ite.maptech
{
	import de.ms_ite.events.*;
	import de.ms_ite.maptech.symbols.styles.*;
	
	import flash.events.*;
	
	import mx.charts.*;
	import mx.charts.chartClasses.*;
	import mx.charts.series.*;
	import mx.charts.series.items.*;
	import mx.containers.Canvas;
	import mx.events.*;

	public class ChartRenderQueue extends Canvas
	{
		protected var _style:SymbolStyle;
		protected var _fields:Array;
		
		protected var _chart:ChartBase;
		
		protected var _queue:Array;
		
		public function ChartRenderQueue()
		{
			super();
			
			_queue = new Array();
			visible = false;
		}

		public function set style( st:SymbolStyle):void {
			_style = st;
			_fields = buildChart();
		}
		
		public function queue( item:Object):void {
			_queue.push( item);

			if (( _fields == null) ? true : (_fields.length == 0)) return;			
			if ( _queue.length == 1) renderSymbol( item, _fields);
		}
		
		//------------------------------------------------------------------------------
		// _charting functions
		
		public function buildChart():Array {
			debug( "set fx: "+_style.data.vis_fx);
			var fields:Array = _style.data.vis_fields.split(',');					

			if ( _chart != null) {
				var delChart:Boolean = false;
				
				switch( _style.data.vis_fx) {
					case 'pie': if (!( _chart is PieChart)) delChart = true; break;
					case 'column': if (!( _chart is ColumnChart)) delChart = true; break;
					case 'bar': if (!( _chart is BarChart)) delChart = true; break;
					case 'none': delChart = true; break;
				}
				
				// delete chart only of other type is requested
				if ( delChart) {
//					debug( "delete chart");
					removeChild( _chart);
					_chart.removeEventListener( FlexEvent.UPDATE_COMPLETE, chartUpdated);
					_chart = null;
				}
			}
			
			if ( _style.data.vis_fx == 'none') return null;

			var createChart:Boolean = false;
			
			if ( _chart == null) {
				switch( _style.data.vis_fx) {
					case 'pie':
						debug( "adding pie.");
						_chart = new PieChart();
						
						var ps:PieSeries = new PieSeries();
						ps.labelFunction = renderLabelPie;
						ps.field = 'value';
						ps.labelField = 'name';
						ps.nameField = 'name';
						_chart.series = [ps];
						
						createChart = true;
					break;
	
					case 'column':
//						debug( "adding bar.");
						_chart = new ColumnChart();
	
						var cs:ColumnSeries = new ColumnSeries();
						cs.labelFunction = renderLabelColumn;
			//			cs.xField = 'value';
						cs.yField = 'value';
						cs.displayName = 'name';
						_chart.series = [cs];
						
						createChart = true;
					break;
	
					case 'bar': {
//						debug( "adding bar.");
						_chart = new BarChart();
	
						var bs:BarSeries = new BarSeries();
						bs.labelFunction = renderLabelBar;
						bs.xField = 'value';
			//			bs.yField = 'value';
						bs.displayName = 'name';
						_chart.series = [bs];
						
						createChart = true;
					}
					break;
					
					default:
				}
			}

			if ( createChart) {
				_chart.addEventListener( FlexEvent.UPDATE_COMPLETE, chartUpdated);
				_chart.setStyle( 'fontFamily', 'embVerdana');
//				_chart.cacheAsBitmap = true;
				addChild( _chart);
//				debug( "setting up.");
			}
			
			return fields;
		}
		
		protected function renderChart( fields:Array):void {

			// if we have a chart, update data			
			if ( _chart != null) {
//				debug( "adding data. @ "+_style.data.vis_scale);
//				_chart.scaleX = _chart.scaleY = 0.25 * _style.data.vis_scale;

				var hAxis:CategoryAxis;
				
				switch( _style.data.vis_fx) {
					case 'pie':
						_chart.height = 100 * _style.data.vis_scale;
						_chart.width = _chart.height * ((_style.data.vis_labels != 'off') ? 3 : 1);
						hAxis = new CategoryAxis();
						hAxis.dataProvider = _chart.dataProvider;
						hAxis.categoryField = 'name';
						
						PieSeries( _chart.series[ 0]).setStyle( 'labelPosition', (_style.data.vis_labels != 'off')? 'insideWithCallout' : 'none');
						
						PieChart( _chart).radialAxis = hAxis;
					break;
	
					case 'column':
						_chart.height = ((_style.data.vis_labels != 'off') ? 120 : 100) * _style.data.vis_scale;
						_chart.width = Math.max( 100, (50 + fields.length * 40) * _style.data.vis_scale);
						
						hAxis = new CategoryAxis();
						hAxis.dataProvider = _chart.dataProvider;
						hAxis.categoryField = (_style.data.vis_labels != 'off') ? 'name' : '--xxnonexx--';
						
						ColumnChart( _chart).horizontalAxis = hAxis;
					break;
	
					case 'bar':
						_chart.width = ((_style.data.vis_labels != 'off') ? 200 : 120) * _style.data.vis_scale;
						_chart.height = Math.max( 50, (60 + fields.length * 25) * _style.data.vis_scale);
						
						hAxis = new CategoryAxis();
						hAxis.dataProvider = _chart.dataProvider;
						hAxis.categoryField = (_style.data.vis_labels != 'off') ? 'name' : '--xxnonexx--';
						
						BarChart( _chart).verticalAxis = hAxis;
					break;
	
					default:
				}
			}

			if ( _chart != null) {
				_chart.invalidateDisplayList();
			}
		}
		
		protected function renderSymbol( row:Object, fields:Array):void {
			debug( "rendering: "+row);
			addData( row, fields);
			renderChart( fields);
		}
			
		protected function addData( rowData:Object, fields:Array):void {
			
			var dp:Array = new Array();
			for( var i:int = 0; i < fields.length; i++) {
				var temp:Object = new Object();
				temp.name = fields[i];
				temp.value =  parseFloat( rowData[ fields[i]]);
				dp.push( temp);
				debug( "set data("+fields[i]+"): "+rowData[ fields[i]]);
			}
			_chart.dataProvider = dp;
		}
		
		protected function chartUpdated( evt:FlexEvent):void {
			
			var event:RenderEvent = new RenderEvent( RenderEvent.RENDER_COMPLETE);
			event.item = _queue.shift();
			
			debug( "  upd complete: "+event.item+".");
			
			dispatchEvent( event);
			
			if ( _queue.length > 0) renderSymbol( _queue[0], _fields);
		}

		public function renderLabelPie( data:Object, field:String, index:Number, percVal:Number):String {
			debug( "labelFP: "+data.name+"/"+data.value+" "+field+" "+index+" "+percVal);
			
			return getLabel( data.value, data.name);
		}
		
		public function renderLabelColumn( element:ChartItem, series:Series):String {
			var data:ColumnSeriesItem = ColumnSeriesItem(element);        
	        var currentSeries:ColumnSeries = ColumnSeries(series);
			debug( "labelFC: "+data.yNumber+" - "+currentSeries.yField);

	        return getLabel( ''+data.yNumber, ''+currentSeries.yField);
	    }

		public function renderLabelBar( element:ChartItem, series:Series):String {
			var data:BarSeriesItem = BarSeriesItem(element);        
	        var currentSeries:BarSeries = BarSeries(series);
			debug( "labelFB: "+data.xNumber+" - "+currentSeries.xField);

	        return getLabel( ''+data.xNumber, ''+currentSeries.xField);
	    }

		protected function getLabel( data:String, name:String):String {
			var temp:String = '';
			switch( _style.data.vis_labels) {
				case 'data': temp = data;
				break;
				
				case 'name': temp = name;
				break;
				
				case 'both': temp = name+"\n"+data;
				break;
				
				case 'off':
				default:
			}
			
			return temp;
		}
		
		protected function debug( txt:String):void {
//			trace( "DBC CQ: "+txt);
		}
		
	}
}