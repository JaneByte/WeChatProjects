package com.example.freshtime.mapper;

import com.example.freshtime.entity.AddressInfo;
import org.apache.ibatis.annotations.Delete;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Options;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import java.util.List;

@Mapper
public interface AddressMapper {

    @Select("SELECT * FROM address WHERE user_id = #{userId} ORDER BY is_default DESC, id DESC")
    List<AddressInfo> selectByUserId(Long userId);

    @Select("SELECT * FROM address WHERE id = #{id} AND user_id = #{userId} LIMIT 1")
    AddressInfo selectByIdAndUserId(@Param("id") Long id, @Param("userId") Long userId);

    @Select("SELECT * FROM address WHERE id = #{id} LIMIT 1")
    AddressInfo selectById(Long id);

    @Insert("INSERT INTO address(user_id, receiver_name, receiver_phone, province, city, district, detail, is_default) " +
            "VALUES(#{userId}, #{receiverName}, #{receiverPhone}, #{province}, #{city}, #{district}, #{detail}, #{isDefault})")
    @Options(useGeneratedKeys = true, keyProperty = "id")
    int insertAddress(AddressInfo addressInfo);

    @Update("UPDATE address SET receiver_name = #{receiverName}, receiver_phone = #{receiverPhone}, province = #{province}, " +
            "city = #{city}, district = #{district}, detail = #{detail}, is_default = #{isDefault} " +
            "WHERE id = #{id} AND user_id = #{userId}")
    int updateAddress(AddressInfo addressInfo);

    @Update("UPDATE address SET is_default = 0 WHERE user_id = #{userId}")
    int clearDefaultByUserId(Long userId);

    @Delete("DELETE FROM address WHERE id = #{id} AND user_id = #{userId}")
    int deleteByIdAndUserId(@Param("id") Long id, @Param("userId") Long userId);
}
