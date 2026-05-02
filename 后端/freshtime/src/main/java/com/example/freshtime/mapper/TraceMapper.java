package com.example.freshtime.mapper;

import com.example.freshtime.entity.TraceRecordInfo;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

@Mapper
public interface TraceMapper {

    @Select("SELECT tr.id, tr.goods_id, tr.origin_card_id, hoc.origin_name, hoc.card_desc, hoc.card_meta, " +
            "tr.location, tr.harvest_date, tr.batch_no, tr.cold_chain_status, tr.status, tr.create_time " +
            "FROM trace_record tr " +
            "LEFT JOIN home_origin_card hoc ON hoc.id = tr.origin_card_id " +
            "WHERE tr.goods_id = #{goodsId} AND tr.status = 1 " +
            "ORDER BY tr.id DESC LIMIT 1")
    TraceRecordInfo selectLatestByGoodsId(@Param("goodsId") Long goodsId);
}
