package com.hongmeng.gcgyy.controller.monitor;

import java.util.Date;
import java.util.LinkedList;
import java.util.List;

import org.apache.commons.lang.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

import com.hongmeng.gcgyy.common.ReturnStatus;
import com.hongmeng.gcgyy.common.utils.FormulaUtils;
import com.hongmeng.gcgyy.entity.Output;
import com.hongmeng.gcgyy.entity.OutputList;
import com.hongmeng.gcgyy.entity.authority.BaseEnterpriseEntity;
import com.hongmeng.gcgyy.entity.baseData.AreaEntity;
import com.hongmeng.gcgyy.entity.baseData.ProductTypeEntity;
import com.hongmeng.gcgyy.entity.monitor.TargetEntity;
import com.hongmeng.gcgyy.service.authority.EnterpriseService;
import com.hongmeng.gcgyy.service.baseData.AreaService;
import com.hongmeng.gcgyy.service.baseData.ProductTypeService;
import com.hongmeng.gcgyy.service.monitor.TargetService;
import com.hongmeng.gcgyy.service.monitor.TargetVO;

@RestController
@RequestMapping("target")
public class TargetController {

	static Logger log = LoggerFactory.getLogger(TargetController.class);

	@Autowired
	TargetService targetService;

	@Autowired
	EnterpriseService enterpriseService;

	@Autowired
	AreaService areaService;

	@Autowired
	ProductTypeService productTypeService;

	@RequestMapping(value = "/add", method = RequestMethod.POST)
	public Output add(String monthly, Long enterpriseId, double mainBusiness, double electricity, double profit,
			double tax) {
		try {
			TargetEntity target = targetService.findOne(monthly, enterpriseId);
			if (target != null) {
				return new Output(null, ReturnStatus.EXISTED.status(), ReturnStatus.EXISTED.msg());
			}

			BaseEnterpriseEntity enterprise = enterpriseService.findOneBase(enterpriseId);
			target = new TargetEntity(monthly, enterprise, mainBusiness, electricity, profit, tax);
			target.setCreateTime(new Date());
			targetService.save(target);

			return new Output(null, ReturnStatus.SUCCESS.status(), ReturnStatus.SUCCESS.msg());
		} catch (Exception e) {
			log.error(e.getMessage(), e);
			return new Output(null, ReturnStatus.FAILED.status(), e.getMessage());
		}
	}

	@RequestMapping(value = "/edit", method = RequestMethod.POST)
	public Output edit(Long targetId, double mainBusiness, double electricity, double profit, double tax) {
		try {
			TargetEntity target = targetService.findOne(targetId);
			target.setMainBusiness(mainBusiness);
			target.setElectricity(electricity);
			target.setProfit(profit);
			target.setTax(tax);
			targetService.save(target);

			return new Output(null, ReturnStatus.SUCCESS.status(), ReturnStatus.SUCCESS.msg());
		} catch (Exception e) {
			log.error(e.getMessage(), e);
			return new Output(null, ReturnStatus.FAILED.status(), e.getMessage());
		}
	}

	@RequestMapping(value = "/delete", method = RequestMethod.POST)
	public Output delete(String targetIds) {
		try {
			List<Long> list = new LinkedList<>();
			for (String idStr : StringUtils.split(targetIds, ",")) {
				list.add(Long.parseLong(idStr));
			}
			targetService.delete(list);

			return new Output(null, ReturnStatus.SUCCESS.status(), ReturnStatus.SUCCESS.msg());
		} catch (Exception e) {
			if (e.getCause().toString().indexOf("ConstraintViolationException") != -1) {
				return new Output(null, ReturnStatus.CONSTRAINT.status(), e.getMessage());
			}
			log.error(e.getMessage(), e);
			return new Output(null, ReturnStatus.FAILED.status(), e.getMessage());
		}
	}

	@RequestMapping(value = "detail", method = RequestMethod.POST)
	public Output detail(Long targetId) {
		try {
			TargetEntity target = targetService.findOne(targetId);
			return new Output(target, ReturnStatus.SUCCESS.status(), ReturnStatus.SUCCESS.msg());
		} catch (Exception e) {
			log.error(e.getMessage(), e);
			return new Output(null, ReturnStatus.FAILED.status(), e.getMessage());
		}
	}
	
	@RequestMapping(value = "listByMonthly", method = RequestMethod.POST)
	public OutputList listByMonthly(String monthly) {
		try {
			List<TargetVO> list = new LinkedList<>();

			List<BaseEnterpriseEntity> enterpriseList = enterpriseService.listBase();
			for (BaseEnterpriseEntity enterprise : enterpriseList) {
				list.add(targetService.detail(monthly, enterprise));
			}

			return new OutputList(list, ReturnStatus.SUCCESS.status(), ReturnStatus.SUCCESS.msg());
		} catch (Exception e) {
			log.error(e.getMessage(), e);
			return new OutputList(null, ReturnStatus.FAILED.status(), e.getMessage());
		}
	}
	
	@RequestMapping(value = "/listByMonthlyPaging", method = RequestMethod.POST)
	public OutputList listByMonthlyPaging(String monthly, int page, int size) {
		try {
			List<TargetVO> list = new LinkedList<>();

			List<BaseEnterpriseEntity> enterpriseList = enterpriseService.listBase(page, size);
			for (BaseEnterpriseEntity enterprise : enterpriseList) {
				list.add(targetService.detail(monthly, enterprise));
			}

			return new OutputList(list, ReturnStatus.SUCCESS.status(), ReturnStatus.SUCCESS.msg());
		} catch (Exception e) {
			log.error(e.getMessage(), e);
			return new OutputList(null, ReturnStatus.FAILED.status(), e.getMessage());
		}
	}
	
	@RequestMapping(value = "/listByEnterpriseId", method = RequestMethod.POST)
	public OutputList listByEnterpriseId(Long enterpriseId) {
		try {
			List<TargetVO> list = new LinkedList<>();

			List<TargetEntity> targets = targetService.list(enterpriseId);
			for (TargetEntity target : targets) {
				list.add(targetService.detail(target));
			}

			return new OutputList(list, ReturnStatus.SUCCESS.status(), ReturnStatus.SUCCESS.msg());
		} catch (Exception e) {
			log.error(e.getMessage(), e);
			return new OutputList(null, ReturnStatus.FAILED.status(), e.getMessage());
		}
	}
	
	@RequestMapping(value = "/listByEnterpriseIdPaging", method = RequestMethod.POST)
	public OutputList listByEnterpriseIdPaging(Long enterpriseId, int page, int size) {
		try {
			List<TargetVO> list = new LinkedList<>();

			List<TargetEntity> targets = targetService.list(enterpriseId, page, size);
			for (TargetEntity target : targets) {
				list.add(targetService.detail(target));
			}

			return new OutputList(list, ReturnStatus.SUCCESS.status(), ReturnStatus.SUCCESS.msg());
		} catch (Exception e) {
			log.error(e.getMessage(), e);
			return new OutputList(null, ReturnStatus.FAILED.status(), e.getMessage());
		}
	}
	
	@RequestMapping(value = "/listByProductType", method = RequestMethod.POST)
	public OutputList listByProductType(String monthly) {
		try {
			List<TargetVO> retList = new LinkedList<>();

			List<ProductTypeEntity> productTypeList = productTypeService.list();
			for (ProductTypeEntity productType : productTypeList) {
				List<BaseEnterpriseEntity> enterpriseList = enterpriseService.listByProductTypeId(productType.getId());
				TargetVO ret = targetService.sumEnterpriseTarget(monthly, enterpriseList);
				ret.setProductType(productType);
				retList.add(ret);
			}

			return new OutputList(retList, ReturnStatus.SUCCESS.status(), ReturnStatus.SUCCESS.msg());
		} catch (Exception e) {
			log.error(e.getMessage(), e);
			return new OutputList(null, ReturnStatus.FAILED.status(), e.getMessage());
		}
	}

	@RequestMapping(value = "/listByArea", method = RequestMethod.POST)
	public OutputList listByArea(String monthly) {
		try {
			List<TargetVO> retList = new LinkedList<>();

			List<AreaEntity> areaList = areaService.list();
			for (AreaEntity area : areaList) {
				List<BaseEnterpriseEntity> enterpriseList = enterpriseService.listByAreaId(area.getId());
				TargetVO ret = targetService.sumEnterpriseTarget(monthly, enterpriseList);
				ret.setArea(area);
				retList.add(ret);
			}

			return new OutputList(retList, ReturnStatus.SUCCESS.status(), ReturnStatus.SUCCESS.msg());
		} catch (Exception e) {
			log.error(e.getMessage(), e);
			return new OutputList(null, ReturnStatus.FAILED.status(), e.getMessage());
		}
	}

	@RequestMapping(value = "/listByMonthlyRange", method = RequestMethod.POST)
	public OutputList listByMonthlyRange(Long enterpriseId, String monthlyStart, String monthlyEnd) {
		try {
			List<TargetVO> list = new LinkedList<>();

			List<String> monthlyList = FormulaUtils.getMonthlyList(monthlyStart, monthlyEnd);
			List<TargetEntity> targets = targetService.listByMonthlyInAndEnterpriseId(monthlyList, enterpriseId);
			for (TargetEntity target : targets) {
				list.add(targetService.detail(target));
			}

			return new OutputList(list, ReturnStatus.SUCCESS.status(), ReturnStatus.SUCCESS.msg());
		} catch (Exception e) {
			log.error(e.getMessage(), e);
			return new OutputList(null, ReturnStatus.FAILED.status(), e.getMessage());
		}
	}

	@RequestMapping(value = "/listRange", method = RequestMethod.POST)
	public OutputList listRange(String monthlyStart, String monthlyEnd) {
		try {
			List<TargetVO> list = new LinkedList<>();

			List<BaseEnterpriseEntity> enterpriseList = enterpriseService.listBase();
			List<String> monthlyList = FormulaUtils.getMonthlyList(monthlyStart, monthlyEnd);
			for (String monthly : monthlyList) {
				TargetVO ret = targetService.sumEnterpriseTarget(monthly, enterpriseList);
				list.add(ret);
			}

			return new OutputList(list, ReturnStatus.SUCCESS.status(), ReturnStatus.SUCCESS.msg());
		} catch (Exception e) {
			log.error(e.getMessage(), e);
			return new OutputList(null, ReturnStatus.FAILED.status(), e.getMessage());
		}
	}

	@RequestMapping(value = "/listByEnterpriseIdRange", method = RequestMethod.POST)
	public OutputList listByEnterpriseIdRange(Long enterpriseId, String monthlyStart,
			String monthlyEnd) {
		try {
			List<TargetVO> list = new LinkedList<>();

			BaseEnterpriseEntity enterprise = enterpriseService.findOneBase(enterpriseId);
			List<BaseEnterpriseEntity> enterpriseList = new LinkedList<>();
			enterpriseList.add(enterprise);

			List<String> monthlyList = FormulaUtils.getMonthlyList(monthlyStart, monthlyEnd);
			for (String monthly : monthlyList) {
				TargetVO ret = targetService.detail(monthly, enterprise);
				list.add(ret);
			}

			return new OutputList(list, ReturnStatus.SUCCESS.status(), ReturnStatus.SUCCESS.msg());
		} catch (Exception e) {
			log.error(e.getMessage(), e);
			return new OutputList(null, ReturnStatus.FAILED.status(), e.getMessage());
		}
	}

	@RequestMapping(value = "/listByProductTypeIdRange", method = RequestMethod.POST)
	public OutputList listByProductTypeIdRange(Long productTypeId, String monthlyStart,
			String monthlyEnd) {
		try {
			List<TargetVO> list = new LinkedList<>();

			ProductTypeEntity productType = productTypeService.findOne(productTypeId);
			List<BaseEnterpriseEntity> enterpriseList = enterpriseService.listByProductTypeId(productTypeId);
			List<String> monthlyList = FormulaUtils.getMonthlyList(monthlyStart, monthlyEnd);
			for (String monthly : monthlyList) {
				TargetVO ret = targetService.sumEnterpriseTarget(monthly, enterpriseList);
				ret.setProductType(productType);
				list.add(ret);
			}

			return new OutputList(list, ReturnStatus.SUCCESS.status(), ReturnStatus.SUCCESS.msg());
		} catch (Exception e) {
			log.error(e.getMessage(), e);
			return new OutputList(null, ReturnStatus.FAILED.status(), e.getMessage());
		}
	}

	@RequestMapping(value = "/listByAreaIdRange", method = RequestMethod.POST)
	public OutputList listByAreaIdRange(Long areaId, String monthlyStart,
			String monthlyEnd) {
		try {
			List<TargetVO> list = new LinkedList<>();

			AreaEntity area = areaService.findOne(areaId);
			List<BaseEnterpriseEntity> enterpriseList = enterpriseService.listByAreaId(area.getId());
			List<String> monthlyList = FormulaUtils.getMonthlyList(monthlyStart, monthlyEnd);
			for (String monthly : monthlyList) {
				TargetVO ret = targetService.sumEnterpriseTarget(monthly, enterpriseList);
				ret.setArea(area);
				list.add(ret);
			}

			return new OutputList(list, ReturnStatus.SUCCESS.status(), ReturnStatus.SUCCESS.msg());
		} catch (Exception e) {
			log.error(e.getMessage(), e);
			return new OutputList(null, ReturnStatus.FAILED.status(), e.getMessage());
		}
	}
	
	@RequestMapping(value = "/listPointEnterpriseRange", method = RequestMethod.POST)
	public OutputList listPointEnterpriseRange(String monthlyStart, String monthlyEnd) {
		try {
			List<TargetVO> list = new LinkedList<>();

			List<BaseEnterpriseEntity> enterpriseList = enterpriseService.listPoint();
			List<String> monthlyList = FormulaUtils.getMonthlyList(monthlyStart, monthlyEnd);
			for (String monthly : monthlyList) {
				TargetVO ret = targetService.sumEnterpriseTarget(monthly, enterpriseList);
				list.add(ret);
			}

			return new OutputList(list, ReturnStatus.SUCCESS.status(), ReturnStatus.SUCCESS.msg());
		} catch (Exception e) {
			log.error(e.getMessage(), e);
			return new OutputList(null, ReturnStatus.FAILED.status(), e.getMessage());
		}
	}

}
