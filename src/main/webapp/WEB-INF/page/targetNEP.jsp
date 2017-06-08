<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<style type="text/css">
.targetEP select {
	height: 2.6rem;
	width: 200px;
}
</style>

<script class="template TargetEP" type="text/x-jquery-tmpl">
<div class="admin-content targetEP" style="height: auto!important;">

	<div class="am-cf am-padding">
		<div class="am-fl am-cf"><strong class="am-text-primary am-text-lg">{{=it.title}}</strong></div>
	</div>

	<div class="am-g">
		<div class="am-u-sm-12">
			<div class="padding-horizontal-o" style="height: 50px;">
				<input id="monthlyStart" type="text" class="am-form-field am-align-left datetimepicker monthly" style="height: 30px; line-height: 16px;width: 150px;" placeholder="请选择年月"/>
				<label class="am-form-label am-text-sm am-align-left" style="line-height: 2.8rem;">到</label>
				<input id="monthlyEnd" type="text" class="am-form-field am-align-left datetimepicker monthly" style="height: 30px; line-height: 16px;width: 150px;" placeholder="请选择年月"/>

				<button type="button" class="am-btn am-radius am-btn-default am-btn-sm search">查询</button>
			</div>			
		</div>

		<div class="am-g">
			<div class="sk-three-bounce">
				<div class="sk-child sk-bounce1"></div>
				<div class="sk-child sk-bounce2"></div>
				<div class="sk-child sk-bounce3"></div>
			</div>
			<div class="am-u-sm-12 targetEP-panel"></div>
		</div>

	</div>
</div>
</script>

<script class="template EconomicTargetEP" type="text/x-jquery-tmpl">
	<div class="am-panel am-panel-primary" style="margin: 0 20px 20px 20px;">
  		<div class="am-panel-hd">{{=it.title}}图表分析</div>
 		<div class="am-panel-bd" id="economic-chart-container">
  		</div>
	</div>

	<div class="am-panel am-panel-primary" style="margin: 0 20px 20px 20px;">
  		<div class="am-panel-hd">{{=it.title}}数据详情</div>
 		<div class="am-panel-bd">
  			<table class="am-table am-table-striped am-table-hover table-main" id="economicTargetEP-table">
				<thead>
					<tr>
						<th class="table-id">#</th>
						<th>月份</th>
						<th>本月止{{=it.title}}
							{{? it.subItem == '2'}}(万度)
							{{??}}(万元)
							{{?}}
						</th>
						<th>同比增长%</th>
						<th>环比增长%</th>
					</tr>
				</thead>
				<tbody>
					{{~ it.data : data : index}}
					<tr class="table-tr">
						<td>{{=index+1}}</td>
						<td class="">{{=data.monthly || ""}}</td>
						{{? it.subItem == '1'}}
							<td>{{=data.target_current !=null ? data.target_current.mainBusiness : "-"}}</td>
							<td>{{=data.mainBusiness_yearGrowth !=null ? (data.mainBusiness_yearGrowth*100).toFixed(2) : "-"}}</td>
							<td>{{=data.mainBusiness_monthGrowth !=null ? (data.mainBusiness_monthGrowth*100).toFixed(2) : "-"}}</td>
						{{?? it.subItem == '2'}}
							<td>{{=data.target_current !=null ? data.target_current.electricity : "-"}}</td>
							<td>{{=data.electricity_yearGrowth !=null ? (data.electricity_yearGrowth*100).toFixed(2) : "-"}}</td>
							<td>{{=data.electricity_monthGrowth !=null ? (data.electricity_monthGrowth*100).toFixed(2) : "-"}}</td>
						{{?? it.subItem == '3'}}
							<td>{{=data.target_current !=null ? data.target_current.profit : "-"}}</td>
							<td>{{=data.profit_yearGrowth !=null ? (data.profit_yearGrowth*100).toFixed(2) : "-"}}</td>
							<td>{{=data.profit_monthGrowth !=null ? (data.profit_monthGrowth*100).toFixed(2) : "-"}}</td>
						{{?? it.subItem == '4'}}
							<td>{{=data.target_current !=null ? data.target_current.tax : "-"}}</td>
							<td>{{=data.tax_yearGrowth !=null ? (data.tax_yearGrowth*100).toFixed(2) : "-"}}</td>
							<td>{{=data.tax_monthGrowth !=null ? (data.tax_monthGrowth*100).toFixed(2) : "-"}}</td>
						{{?}}
					</tr>
					{{~}}
				</tbody>
			</table>
  		</div>
	</div>
</script>

<script type="text/javascript">
;(function( $ ) {
	
	var fnName = "TargetEP";
	var Klass = $k.proto[fnName] = function() {};
	Klass.prototype = Object.create(Object.prototype, {
		$tempTar: {
			value: $(".template." + fnName)
		},
		init: {
			value: function($tar) {
				var self = this;
				self.$tar = $tar
				.on('click', '.search', function() {
					self.reload(self.id);
				});
				return self;
			}
		},
		draw: {
			value: function(type) {
				var self = this;
				self.type = type;
				
				$k.util.getEnterprise({
					success: function(data) {
						if(data.data != null && data.data.length != 0) {
							self.id = data.data.id;
							self.$tar.html(self.$tempTar.doT({
								title: self.getNavTitle(type, data.data.name),
								item: self.getItem(type)
							}));
							self.initTime();
							self.reload(data.data.id);
						}
					}
				});
				return self;
			}
		},
		initTime: {
			value: function() {
				var self = this;
				
				var now = new Date();
				// start time
				$k.util.datePicker(self.$tar.find("#monthlyStart"));
				now.setYear(now.getFullYear() - 1);
				self.$tar.find("#monthlyStart").val(now.format("yyyy-mm"));
				// end time 
				$k.util.datePicker(self.$tar.find("#monthlyEnd"));
				now.setDate(1);
				now.setMonth(now.getMonth() - 1);
				now.setYear(now.getFullYear() + 1);
				self.$tar.find("#monthlyEnd").val(now.format("yyyy-mm"));
				
				return self;
			}
		},
		reload: {
			value: function(id) {
				var self = this;
				if (self.table) {
					self.table.fnDestroy();
				}
				
				var monthlyStart = self.$tar.find("#monthlyStart").val();
				var monthlyEnd = self.$tar.find("#monthlyEnd").val();
				
				var subItem = self.getSubItem(self.type);
				
				var url, data;
				var $template, chart, table;
				
				var overViewData = {
					monthlyStart: monthlyStart,
					monthlyEnd: monthlyEnd
				};
				var enterpriseData = {
						enterpriseId: id,
						monthlyStart: monthlyStart,
						monthlyEnd: monthlyEnd
					};
				
				self.$tar.find(".target-panel").html("");
				self.$tar.find(".sk-three-bounce").show();
				
				if (id == '0') // 总览
				{
					url = 'target/listRange';
					data = overViewData;
					chart = "#economic-chart-container";
				}
				else 
				{
					chart = "#economic-chart-container";
					url = 'target/listByEnterpriseIdRange';
					data = enterpriseData;
				}
				
				$.ajax({
					url: url,
					type: 'POST',
					data: data,
					success: function(data) {
						self.$tar.find(".sk-three-bounce").hide();
						self.$tar.find(".targetEP-panel").html(
							$(".template.EconomicTargetEP").doT({
								title: self.getItemTitle(self.type),
								subItem: self.getSubItem(self.type),
								data: data.data, 
							})
						);
						self.table = self.$tar.find("#economicTargetEP-table").dataTable();
						self.getChart(subItem, data.data, self.$tar.find(chart));
					},
					error: function(err) {}
				});
				
				return self;
			}
		},
		load: {
			value: function() {
				var self = this;
				return self;
			}
		},
		getItem: {
			value: function(type) {
				return type.split('-')[0];
			}
		},
		getSubItem: {
			value: function(type) {
				return type.split('-')[1];
			}
		},
		getNavTitle: {
			value: function(type, enterpriseName) {
				var self = this;
				return enterpriseName + " > " + self.getItemTitle(type);
			}
		},
		getItemTitle: {
			value: function(type) {
				var title;
				switch (type.split('-')[1]) {
				case '1':	title = subItemTitle = '主营业务收入';		break;
				case '2':	title = subItemTitle = '用电量';		break;
				case '3':	title = subItemTitle = '利润总额';			break;
				case '4':	title = subItemTitle = '税金总额';			break;
				}
				return title;
			}
		},
		getChart: {
			value: function(subItem, data, $obj) {
				var self = this;
				self.getCommonChart(data, $obj);
			}
		},
		getCommonChart: {
			value: function(data, $obj) {
				var self = this;
				if(data == null) {
					$obj.html("没有可展示的数据");
					return;
				} else {
					$obj.html("");
				}
				
				var subItem = self.getSubItem(self.type);
				var xAxisArr = [];
				var arr1 = [];
				var arr2 = [];
				var arr3 = [];
				var text1 = "";
				var unit = "";
				$.each(data, function(key, val) {
					xAxisArr.push(val.monthly);
					if(subItem == "1") {
						text1 = "本月止主营业务收入";
						unit = "万元";
						var mainBusiness = val.target_current != null ? val.target_current.mainBusiness : 0;
						var mainBusiness_yearGrowth = val.mainBusiness_yearGrowth != null && val.mainBusiness_yearGrowth != "" ? (parseFloat(val.mainBusiness_yearGrowth)*100).toFixed(2) : 0;
						var mainBusiness_monthGrowth = val.mainBusiness_monthGrowth != null && val.mainBusiness_monthGrowth != "" ? (parseFloat(val.mainBusiness_monthGrowth)*100).toFixed(2) : 0;
						arr1.push({y: mainBusiness, extra: val.target_current==null ? "-" : mainBusiness + "万元"});
						arr2.push({y: parseFloat(mainBusiness_yearGrowth), extra: val.mainBusiness_yearGrowth==null ? "-" : mainBusiness_yearGrowth});
						arr3.push({y: parseFloat(mainBusiness_monthGrowth), extra: val.mainBusiness_monthGrowth==null ? "-" : mainBusiness_monthGrowth});
					} else if(subItem == "2") {
						text1 = "本月止用电量";
						unit = "万度";
						var electricity = val.target_current != null ? val.target_current.electricity : 0;
						var electricity_yearGrowth = val.electricity_yearGrowth != null && val.electricity_yearGrowth != "" ? (parseFloat(val.electricity_yearGrowth)*100).toFixed(2) : 0;
						var electricity_monthGrowth = val.electricity_monthGrowth != null && val.electricity_monthGrowth != "" ? (parseFloat(val.electricity_monthGrowth)*100).toFixed(2) : 0;
						arr1.push({y: electricity, extra: val.target_current==null ? "-" : electricity + "万元"});
						arr2.push({y: parseFloat(electricity_yearGrowth), extra: val.electricity_yearGrowth==null ? "-" : electricity_yearGrowth});
						arr3.push({y: parseFloat(electricity_monthGrowth), extra: val.electricity_monthGrowth==null ? "-" : electricity_monthGrowth});
					} else if(subItem == "3") {
						text1 = "本月止利润总额";
						unit = "万元";
						var profit = val.target_current != null ? val.target_current.profit : 0;
						var profit_yearGrowth = val.profit_yearGrowth != null && val.profit_yearGrowth != "" ? (parseFloat(val.profit_yearGrowth)*100).toFixed(2) : 0;
						var profit_monthGrowth = val.profit_monthGrowth != null && val.profit_monthGrowth != "" ? (parseFloat(val.profit_monthGrowth)*100).toFixed(2) : 0;
						arr1.push({y: profit, extra: val.target_current==null ? "-" : profit + "万元"});
						arr2.push({y: parseFloat(profit_yearGrowth), extra: val.profit_yearGrowth==null ? "-" : profit_yearGrowth});
						arr3.push({y: parseFloat(profit_monthGrowth), extra: val.profit_monthGrowth==null ? "-" : profit_monthGrowth});
					} else if(subItem == "4") {
						text1 = "本月止实现税金总额";
						unit = "万元";
						var tax = val.target_current != null ? val.target_current.tax : 0;
						var tax_yearGrowth = val.tax_yearGrowth != null && val.tax_yearGrowth != "" ? (parseFloat(val.tax_yearGrowth)*100).toFixed(2) : 0;
						var tax_monthGrowth = val.tax_monthGrowth != null && val.tax_monthGrowth != "" ? (parseFloat(val.tax_monthGrowth)*100).toFixed(2) : 0;
						arr1.push({y: tax, extra: val.target_current==null ? "-" : tax + "万元"});
						arr2.push({y: parseFloat(tax_yearGrowth), extra: val.tax_yearGrowth==null ? "-" : tax_yearGrowth});
						arr3.push({y: parseFloat(tax_monthGrowth), extra: val.tax_monthGrowth==null ? "-" : tax_monthGrowth});
					}
	            });
				$obj.highcharts({
					chart: { zoomType: 'xy' }, 
					credits: { enabled: false }, 
					title: { text: '' },
					xAxis: [{ 
						categories: xAxisArr
					}], 
					yAxis: [{ // Primary yAxis
			            labels: {
			                formatter: function() {
			                    return this.value +'%';
			                },
			            },
			            title: {
			                text: '',
			            },
			            opposite: true

			        },{ 
			            title: {
			                text: unit,
			            },
			            labels: {
			                formatter: function() {
			                    return this.value;
			                },
			            }

			        }], 
					tooltip: { shared: true }, 
					series: [{ 
						name: text1, 
						color: '#4572A7', 
						type: 'column', 
						data: arr1,
						yAxis: 1,
						tooltip: { 
							valueSuffix: ' '+unit,
							pointFormat: '<tr><td style="color: {series.color}">{series.name}: </td>' +
				            '<td style="text-align: right"><b>{point.extra}</b></td></tr><br/>',
						}
					},
					{ 
						name: "同比增长%", 
						color: '#3bb4f2', 
						type: 'spline', 
						data: arr2,
						tooltip: { 
							valueSuffix: ' %',
							pointFormat: '<tr><td style="color: {series.color}">{series.name}: </td>' +
				            '<td style="text-align: right"><b>{point.extra}</b></td></tr><br/>',
						} 
					},
					{ 
					    name: '环比增长%', 
					    color: '#F7A35C', 
					    type: 'spline', 
					    data: arr3, 
					    tooltip: { 
					    	valueSuffix: '%', 
					    	pointFormat: '<tr><td style="color: {series.color}">{series.name}: </td>' +
				            '<td style="text-align: right"><b>{point.extra}</b></td></tr><br/>',
					    } 
					}] 
				});
			}
		}
	});
	
})( jQuery );
</script>