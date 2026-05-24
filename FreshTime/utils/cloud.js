// utils/cloud.js

function isCloudFileId(value) {
  return typeof value === 'string' && value.startsWith('cloud://');
}

function getFileExtension(filePath = '') {
  const match = `${filePath || ''}`.match(/(\.[a-zA-Z0-9]+)(?:[\?#].*)?$/);
  return match && match[1] ? match[1].toLowerCase() : '.jpg';
}

/**
 * 根据 cloud 文件 ID 列表换取临时 URL
 * @param {Array<string>} fileIds cloud:// 文件 ID
 * @returns {Promise<Object>} { fileID: tempFileURL }
 */
async function getTempFileUrls(fileIds) {
  if (!fileIds || fileIds.length === 0) {
    return {};
  }

  try {
    const res = await wx.cloud.getTempFileURL({
      fileList: fileIds.filter((id) => isCloudFileId(id))
    });

    const urlMap = {};
    (res.fileList || []).forEach((file) => {
      if (file.tempFileURL) {
        urlMap[file.fileID] = file.tempFileURL;
      }
    });

    return urlMap;
  } catch (err) {
    console.error('获取临时 URL 失败', err);
    return {};
  }
}

async function resolveImageUrl(fileIdOrUrl = '') {
  const raw = `${fileIdOrUrl || ''}`.trim();
  if (!raw) return '';
  if (!isCloudFileId(raw)) return raw;
  const urlMap = await getTempFileUrls([raw]);
  return urlMap[raw] || '';
}

async function uploadAvatarToCloud(filePath, userId) {
  if (!filePath) {
    throw new Error('头像文件不能为空');
  }
  const extension = getFileExtension(filePath);
  const safeUserId = Number(userId || 0) > 0 ? Number(userId) : Date.now();
  const cloudPath = `avatars/${safeUserId}_${Date.now()}${extension}`;
  const res = await wx.cloud.uploadFile({
    cloudPath,
    filePath
  });
  return (res && res.fileID) || '';
}

/**
 * 处理商品列表图片（cloud:// -> 临时 URL）
 * @param {Array} goodsList 商品列表
 * @param {Function} setData 页面/组件 setData
 * @param {String} dataKey 数据字段，默认 goodsList
 */
async function processGoodsImages(goodsList, setData, dataKey = 'goodsList') {
  if (!goodsList || goodsList.length === 0) return;

  const fileIds = goodsList
    .map((item) => item.mainImage || item.image)
    .filter((id) => isCloudFileId(id));

  if (fileIds.length === 0) return;

  const urlMap = await getTempFileUrls(fileIds);

  const updatedList = goodsList.map((item) => {
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

module.exports = {
  isCloudFileId,
  getTempFileUrls,
  processGoodsImages,
  resolveImageUrl,
  uploadAvatarToCloud
};
