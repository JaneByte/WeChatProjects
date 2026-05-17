import axios from 'axios';

const ADMIN_TOKEN_KEY = 'adminToken';
const ADMIN_INFO_KEY = 'adminInfo';
const DEFAULT_API_ORIGIN = 'http://127.0.0.1:8080';
const API_ORIGIN = (import.meta.env.VITE_API_ORIGIN || DEFAULT_API_ORIGIN).replace(/\/+$/, '');
const ADMIN_API_BASE = `${API_ORIGIN}/api/admin`;
const FILE_API_BASE = `${API_ORIGIN}/api`;
const FILE_HOST = API_ORIGIN;

export const http = axios.create({
  baseURL: ADMIN_API_BASE,
  timeout: 10000
});

export const authHttp = axios.create({
  baseURL: ADMIN_API_BASE,
  timeout: 10000
});

export const uploadHttp = axios.create({
  baseURL: FILE_API_BASE,
  timeout: 10000
});

http.interceptors.request.use((config) => {
  const token = window.localStorage.getItem(ADMIN_TOKEN_KEY) || '';
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

http.interceptors.response.use(
  (response) => response.data,
  (error) => {
    const message = error?.response?.data?.message || error?.message || '请求失败';
    return Promise.reject(new Error(message));
  }
);

uploadHttp.interceptors.request.use((config) => {
  const token = window.localStorage.getItem(ADMIN_TOKEN_KEY) || '';
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

uploadHttp.interceptors.response.use(
  (response) => response.data,
  (error) => {
    const message = error?.response?.data?.message || error?.message || '请求失败';
    return Promise.reject(new Error(message));
  }
);

export function saveAdminSession({ token, adminInfo }) {
  if (token) {
    window.localStorage.setItem(ADMIN_TOKEN_KEY, token);
  }
  if (adminInfo) {
    window.localStorage.setItem(ADMIN_INFO_KEY, JSON.stringify(adminInfo));
  }
}

export function clearAdminSession() {
  window.localStorage.removeItem(ADMIN_TOKEN_KEY);
  window.localStorage.removeItem(ADMIN_INFO_KEY);
}

export function getAdminToken() {
  return window.localStorage.getItem(ADMIN_TOKEN_KEY) || '';
}

export function getAdminInfo() {
  const raw = window.localStorage.getItem(ADMIN_INFO_KEY) || '';
  if (!raw) {
    return null;
  }
  try {
    return JSON.parse(raw);
  } catch (error) {
    return null;
  }
}

export function resolveFileUrl(url) {
  const value = String(url || '').trim();
  if (!value) {
    return '';
  }
  if (value.startsWith('http://') || value.startsWith('https://') || value.startsWith('data:image/')) {
    return value;
  }
  if (value.startsWith('/')) {
    return `${FILE_HOST}${value}`;
  }
  return `${FILE_HOST}/${value.replace(/^\/+/, '')}`;
}
