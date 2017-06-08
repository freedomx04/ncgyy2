package com.hongmeng.gcgyy.service.monitor;

import java.util.List;

import com.hongmeng.gcgyy.entity.authority.BaseEnterpriseEntity;
import com.hongmeng.gcgyy.entity.monitor.TargetEntity;

public interface TargetService {
	
	TargetEntity findOne(Long targetId);
	
	TargetEntity findOne(String monthly, Long enterpriseId);
	
	void save(TargetEntity target);
	
	void delete(List<Long> targetIds);
	
	List<TargetEntity> list(String monthly);
	
	List<TargetEntity> list(String monthly, int page, int size);
	
	List<TargetEntity> list(Long enterpriseId);
	
	List<TargetEntity> list(Long enterpriseId, int page, int size);
	
	List<TargetEntity> listByMonthlyAndEnterpriseIn(String monthly, List<BaseEnterpriseEntity> list);
	
	List<TargetEntity> listByMonthlyInAndEnterpriseId(List<String> monthlyList, Long enterpriseId);
	
	TargetVO detail(TargetEntity target);
	
	TargetVO detail(String monthly, BaseEnterpriseEntity enterprise);
	
	TargetVO sumEnterpriseTarget(String monthly, List<BaseEnterpriseEntity> enterpriseList);

}
