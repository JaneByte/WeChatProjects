// utils/cloud.js

/**
 * 批量转换云存储文件ID为临时URL
 * @param {Array} fileIds - cloud:// 格式的文件ID数组
 * @returns {Promise<Object>} 返回 { fileID: tempFileURL } 的映射对象
 */
async function getTempFileUrls(fileIds) {
  if (!fileIds || fileIds.length === 0) {
    return {};
  }
  
  try {
    const res = await wx.cloud.getTempFileURL({
      fileList: fileIds.filter(id => id && id.startsWith('cloud://'))
    });
    
    const urlMap = {};
    res.fileList.forEach(file => {
      if (file.tempFileURL) {
        urlMap[file.fileID] = file.tempFileURL;
      }
    });
    
    return urlMap;
  } catch (err) {
    console.error('转换云存储图片失败', err);
    return {};
  }
}

/**
 * 处理商品列表的图片（先显示占位，异步更新）
 * @param {Array} goodsList - 商品列表
 * @param {Function} setData - 页面的 setData 方法
 * @param {String} dataKey - 数据字段名，默认 'goodsList'
 */
async function processGoodsImages(goodsList, setData, dataKey = 'goodsList') {
  if (!goodsList || goodsList.length === 0) return;
  
  // 收集所有需要转换的图片
  const fileIds = goodsList
    .map(item => item.mainImage || item.image)
    .filter(id => id && id.startsWith('cloud://'));
  
  if (fileIds.length === 0) return;
  
  // 异步转换图片
  const urlMap = await getTempFileUrls(fileIds);
  
  // 更新数据
  const updatedList = goodsList.map(item => {
    const imageField = item.mainImage || item.image;
    if (imageField && urlMap[imageField]) {
      return { 
        ...item, 
        mainImage: urlMap[imageField],
        image: urlMap[imageField] 
      };
    }
    return item;
  });
  
  setData({ [dataKey]: updatedList });
}

/**
 * 处理单个对象的图片字段
 * @param {Object} data - 数据对象
 * @param {Array} fields - 需要转换的字段名数组，如 ['icon', 'mainImage']
 * @returns {Promise<Object>} 转换后的对象
 */
async function processObjectImages(data, fields = ['icon', 'mainImage', 'image', 'avatar']) {
  if (!data) return data;
  
  const fileIds = [];
  fields.forEach(field => {
    if (data[field] && data[field].startsWith('cloud://')) {
      fileIds.push(data[field]);
    }
  });
  
  if (fileIds.length === 0) return data;
  
  const urlMap = await getTempFileUrls(fileIds);
  
  const result = { ...data };
  fields.forEach(field => {
    if (result[field] && urlMap[result[field]]) {
      result[field] = urlMap[result[field]];
    }
  });
  
  return result;
}

/**
 * 处理分类列表的图标
 * @param {Array} categoryList - 分类列表
 * @param {Function} setData - 页面的 setData 方法
 */
async function processCategoryIcons(categoryList, setData) {
  if (!categoryList || categoryList.length === 0) return;
  
  const fileIds = categoryList
    .map(item => item.icon)
    .filter(id => id && id.startsWith('cloud://'));
  
  if (fileIds.length === 0) return;
  
  const urlMap = await getTempFileUrls(fileIds);
  
  const updatedList = categoryList.map(item => {
    if (item.icon && urlMap[item.icon]) {
      return { ...item, iconUrl: urlMap[item.icon] };
    }
    return { ...item, iconUrl: item.icon };
  });
  
  setData({ categoryList: updatedList });
  return updatedList;
}

module.exports = {
  getTempFileUrls,
  processGoodsImages,
  processObjectImages,
  processCategoryIcons
};