package com.example.freshtime.controller;

import com.example.freshtime.common.ApiResponse;
import com.example.freshtime.dto.UpdateSeasonalConfigRequest;
import com.example.freshtime.service.SeasonalService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RequestBody;

import java.util.Map;

@RestController
@RequestMapping("/api/seasonal")
@CrossOrigin(origins = "*")
public class SeasonalController {

    @Autowired
    private SeasonalService seasonalService;

    @GetMapping("/list")
    public ApiResponse<?> list(@RequestParam(required = false) Integer limit,
                               @RequestParam(required = false) String season,
                               @RequestParam(required = false) String region,
                               @RequestParam(required = false) String budgetLevel,
                               @RequestParam(required = false) String sortBy,
                               @RequestParam(required = false) String produceType,
                               @RequestParam(required = false) Boolean strictTag) {
        return seasonalService.list(limit, season, region, budgetLevel, sortBy, produceType, strictTag);
    }

    @PostMapping("/refresh")
    public ApiResponse<?> refresh(@RequestParam(required = false) Integer limit,
                                  @RequestParam(required = false) String season,
                                  @RequestParam(required = false) String region,
                                  @RequestParam(required = false) String budgetLevel,
                                  @RequestParam(required = false) String sortBy,
                                  @RequestParam(required = false) String produceType,
                                  @RequestParam(required = false) Boolean strictTag,
                                  @RequestBody(required = false) Map<String, Object> body) {
        Integer finalLimit = limit;
        String finalSeason = season;
        String finalRegion = region;
        String finalBudgetLevel = budgetLevel;
        String finalSortBy = sortBy;
        String finalProduceType = produceType;
        Boolean finalStrictTag = strictTag;

        if (body != null) {
            if (finalLimit == null && body.get("limit") != null) {
                try {
                    finalLimit = Integer.valueOf(String.valueOf(body.get("limit")));
                } catch (Exception ignored) {
                    // ignore invalid limit in body
                }
            }
            if ((finalSeason == null || finalSeason.trim().isEmpty()) && body.get("season") != null) {
                finalSeason = String.valueOf(body.get("season"));
            }
            if ((finalRegion == null || finalRegion.trim().isEmpty()) && body.get("region") != null) {
                finalRegion = String.valueOf(body.get("region"));
            }
            if ((finalBudgetLevel == null || finalBudgetLevel.trim().isEmpty()) && body.get("budgetLevel") != null) {
                finalBudgetLevel = String.valueOf(body.get("budgetLevel"));
            }
            if ((finalSortBy == null || finalSortBy.trim().isEmpty()) && body.get("sortBy") != null) {
                finalSortBy = String.valueOf(body.get("sortBy"));
            }
            if ((finalProduceType == null || finalProduceType.trim().isEmpty()) && body.get("produceType") != null) {
                finalProduceType = String.valueOf(body.get("produceType"));
            }
            if (finalStrictTag == null && body.get("strictTag") != null) {
                Object strictRaw = body.get("strictTag");
                if (strictRaw instanceof Boolean) {
                    finalStrictTag = (Boolean) strictRaw;
                } else {
                    finalStrictTag = Boolean.valueOf(String.valueOf(strictRaw));
                }
            }
        }
        return seasonalService.refresh(finalLimit, finalSeason, finalRegion, finalBudgetLevel, finalSortBy, finalProduceType, finalStrictTag);
    }

    @GetMapping("/config")
    public ApiResponse<?> config() {
        return seasonalService.getConfig();
    }

    @PostMapping("/config/update")
    public ApiResponse<?> updateConfig(@RequestBody UpdateSeasonalConfigRequest request) {
        return seasonalService.updateConfig(request);
    }
}
