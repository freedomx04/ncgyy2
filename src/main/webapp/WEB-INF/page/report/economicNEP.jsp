<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<script class="template EconomicEP" type="text/x-jquery-tmpl">
<div class="admin-content economicEP" style="height: auto!important;">

	<div class="am-cf am-padding">
		<div class="am-fl am-cf"><strong class="am-text-primary am-text-lg">主要指标</strong></div>
	</div>

	<div class="am-g">
		<div class="am-u-sm-12" style="height: 50px;">
			<div class="am-fl">
				<input type="text" id="monthlyStart" class="am-form-field am-align-left datetimepicker" style="font-size: 1.4rem; width: 120px;" placeholder="请选择年月"/>
				到
			</div>
			<div class="am-fl">
				<input type="text" id="monthlyEnd" class="am-form-field am-align-left datetimepicker" style="font-size: 1.4rem; width: 120px; margin-left: 1rem;" placeholder="请选择年月"/>
				<button type="button" class="am-btn am-radius am-btn-default am-btn-sm search">查询</button>
			</div>
			<div class="am-fr">
				<div class="am-btn-toolbar am-fl">
		   			<div class="am-btn-group am-btn-group-sm">
						<button type="button" class="am-btn am-btn-default export-btn"><span class="am-icon-save"></span> 导出Excel</button>
		   			</div>
  				</div>
			</div>
		</div>

		<div class="am-u-sm-12">
			<div class="sk-three-bounce">
				<div class="sk-child sk-bounce1"></div>
				<div class="sk-child sk-bounce2"></div>
				<div class="sk-child sk-bounce3"></div>
			</div>
			<table class="am-table am-table-striped am-table-hover table-main" id="economic-table">
			</table>
    	</div>	
	</div>
</div>
</script>

<script type="text/javascript">
;(function( $ ) {
	
	var fnName = "EconomicEP";
	var Klass = $k.proto[fnName] = function() {};
	Klass.prototype = Object.create(Object.prototype, {
		$tempTarEP: {
			value: $(".template." + fnName)
		},
		$tempDialogTar: {
			value: $(".template." + fnName + "Dialog")
		},
		init: {
			value: function($tar) {
				var self = this;
				self.$tar = $tar
				.on('click', '.search', function() {
					self.load();
				})
				.on("click", ".export-btn", function() {
					location.href = "reportForm/exportByEnterpriseId?enterpriseId=" + self.enterpriseId + "&type=604";
				})
				return self;
			}
		},
		draw: {
			value: function() {
				var self = this;
				var monthlyStart = new Date();
				var monthlyEnd = new Date();
				monthlyEnd.setDate(1);
				monthlyStart.setYear(monthlyStart.getFullYear() - 1);
				monthlyEnd.setMonth(monthlyEnd.getMonth() - 1);
				
				self.$tar.html(self.$tempTarEP.doT());
				$k.util.datePicker(self.$tar.find("#monthlyStart"));
				$k.util.datePicker(self.$tar.find("#monthlyEnd"));
				self.$tar.find("#monthlyStart").val(monthlyStart.format("yyyy-mm"));
				self.$tar.find("#monthlyEnd").val(monthlyEnd.format("yyyy-mm"));
				
				return self;
			}
		},
		load: {
			value: function(){
				var self = this;
				if (self.datatables) {
					self.datatables.fnDestroy();
				}
				self.$tar.find(".sk-three-bounce").show();
				self.$tar.find("table").html("");
				$k.util.getEnterprise({
					success: function(enterpriseData) {
						if(enterpriseData.data != null  && enterpriseData.data.length != 0) {
							self.enterpriseId = enterpriseData.data.id;
							
							$.ajax({
								url: "target/listByEnterpriseIdRange",
								type: "POST",
								data: {
									enterpriseId: enterpriseData.data.id,
									monthlyStart: self.$tar.find("#monthlyStart").val(),
									monthlyEnd: self.$tar.find("#monthlyEnd").val()
								},
								success: function(data) {
									self.$tar.find(".sk-three-bounce").hide();
									self.$tar.find("#economic-table").html(
										$(".template.EconomicList").doT({
											data: data.data,
											type: "EP"
										})
									);
									self.datatables = self.$tar.find("#economic-table").dataTable();
								},
								error: function(err) {}
							});
						} else {
							self.datatables = self.$tar.find("#economic-table").dataTable();
						}
					}
				});
				
				return self;
			}
		},
	});
	
})( jQuery );
</script>