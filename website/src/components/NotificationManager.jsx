import React, { useState, useEffect, useRef } from 'react';
import { api } from '../utils/api';

export default function NotificationManager({ showToast }) {
  const [notifications, setNotifications] = useState([]);
  const [loading, setLoading] = useState(false);
  const [searchTerm, setSearchTerm] = useState('');

  // Modal states
  const [formData, setFormData] = useState({
    title: '',
    content: '',
    category: 'Thông báo chung',
    targetGroup: 'ALL'
  });

  const dialogRef = useRef(null);

  useEffect(() => {
    fetchNotifications();
  }, []);

  const fetchNotifications = async () => {
    setLoading(true);
    try {
      const data = await api.getAdminNotifications();
      setNotifications(data);
    } catch (err) {
      showToast(err.message, 'error');
    } finally {
      setLoading(false);
    }
  };

  const handleOpenAddModal = () => {
    setFormData({
      title: '',
      content: '',
      category: 'Thông báo chung',
      targetGroup: 'ALL'
    });
    dialogRef.current?.showModal();
  };

  const handleCloseModal = () => {
    dialogRef.current?.close();
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      await api.sendNotification(formData);
      showToast('Gửi thông báo thành công!', 'success');
      handleCloseModal();
      fetchNotifications();
    } catch (err) {
      showToast(err.message, 'error');
    }
  };

  const handleDelete = async (id) => {
    if (!window.confirm('Bạn có chắc chắn muốn xóa thông báo này?')) {
      return;
    }
    try {
      await api.deleteAdminNotification(id);
      showToast('Xóa thông báo thành công', 'success');
      fetchNotifications();
    } catch (err) {
      showToast(err.message, 'error');
    }
  };

  const filteredNotifications = notifications.filter(n => {
    const term = searchTerm.toLowerCase();
    return (
      n.title?.toLowerCase().includes(term) ||
      n.content?.toLowerCase().includes(term) ||
      n.category?.toLowerCase().includes(term)
    );
  });

  const formatDateTime = (isoStr) => {
    if (!isoStr) return '--';
    try {
      const d = new Date(isoStr);
      return d.toLocaleString('vi-VN');
    } catch (_) {
      return isoStr;
    }
  };

  const getTargetBadgeClass = (target) => {
    if (target?.includes('STUDENT')) return 'badge-student';
    if (target?.includes('TEACHER')) return 'badge-teacher';
    if (target?.includes('PARENT')) return 'badge-warning';
    return 'badge-active';
  };

  return (
    <div>
      {/* Header section */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px' }}>
        <div>
          <h2 style={{ fontSize: '1.5rem', fontWeight: '700', marginBottom: '4px' }}>Quản lý Thông báo</h2>
          <p style={{ color: 'var(--text-secondary)', fontSize: '0.9rem' }}>Phát thông báo trường học tới Học sinh, Giáo viên & Phụ huynh</p>
        </div>
        <button className="btn btn-primary" onClick={handleOpenAddModal}>
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5">
            <line x1="12" y1="5" x2="12" y2="19"></line>
            <line x1="5" y1="12" x2="19" y2="12"></line>
          </svg>
          Phát thông báo mới
        </button>
      </div>

      {/* Filter and Search Bar */}
      <div className="glass-card" style={{ marginBottom: '24px', padding: '16px' }}>
        <div style={{ display: 'flex', gap: '16px', flexWrap: 'wrap' }}>
          <div style={{ flex: 1, minWidth: '240px' }}>
            <input
              type="text"
              className="form-control"
              placeholder="Tìm kiếm tiêu đề, nội dung thông báo..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
            />
          </div>
        </div>
      </div>

      {/* Table section */}
      <div className="glass-card" style={{ padding: 0, overflow: 'hidden' }}>
        {loading ? (
          <div style={{ padding: '40px', textAlign: 'center', color: 'var(--text-secondary)' }}>Đang tải danh sách thông báo...</div>
        ) : filteredNotifications.length === 0 ? (
          <div style={{ padding: '40px', textAlign: 'center', color: 'var(--text-secondary)' }}>Chưa có thông báo nào</div>
        ) : (
          <table className="admin-table">
            <thead>
              <tr>
                <th>Tiêu đề</th>
                <th>Nội dung</th>
                <th>Danh mục</th>
                <th>Đối tượng</th>
                <th>Thời gian</th>
                <th style={{ textAlign: 'right' }}>Thao tác</th>
              </tr>
            </thead>
            <tbody>
              {filteredNotifications.map((n) => (
                <tr key={n.id}>
                  <td>
                    <div style={{ fontWeight: '600', color: 'var(--text-primary)' }}>{n.title}</div>
                  </td>
                  <td style={{ maxWidth: '300px', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis', color: 'var(--text-secondary)' }}>
                    {n.content}
                  </td>
                  <td>
                    <span className="badge" style={{ background: 'rgba(243, 111, 33, 0.1)', color: 'var(--color-accent)' }}>
                      {n.category || 'Thông báo'}
                    </span>
                  </td>
                  <td>
                    <span className={`badge ${getTargetBadgeClass(n.targetGroup)}`}>
                      {n.targetGroup || 'Tất cả'}
                    </span>
                  </td>
                  <td style={{ fontSize: '0.85rem', color: 'var(--text-muted)' }}>
                    {formatDateTime(n.createdAt)}
                  </td>
                  <td style={{ textAlign: 'right' }}>
                    <button
                      className="btn btn-secondary"
                      style={{ padding: '6px 12px', fontSize: '0.85rem', color: '#fca5a5', borderColor: 'rgba(239, 68, 68, 0.2)' }}
                      onClick={() => handleDelete(n.id)}
                    >
                      Xóa
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>

      {/* Modal Dialog for Send Notification */}
      <dialog ref={dialogRef} className="modal">
        <div style={{ width: '100%', maxWidth: '550px' }} className="modal-content">
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
            <h3 style={{ fontSize: '1.25rem', fontWeight: '700' }}>
              Phát thông báo trường học
            </h3>
            <button
              onClick={handleCloseModal}
              style={{ background: 'none', border: 'none', color: 'var(--text-muted)', cursor: 'pointer', fontSize: '1.2rem' }}
            >
              ✕
            </button>
          </div>

          <form onSubmit={handleSubmit}>
            <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
              <div className="form-group">
                <label className="form-label">Tiêu đề thông báo *</label>
                <input
                  type="text"
                  className="form-control"
                  placeholder="Ví dụ: Thông báo nghỉ lễ 30/4 - 1/5"
                  required
                  value={formData.title}
                  onChange={(e) => setFormData({ ...formData, title: e.target.value })}
                />
              </div>

              <div className="form-group">
                <label className="form-label">Nội dung thông báo *</label>
                <textarea
                  className="form-control"
                  rows={4}
                  placeholder="Nhập chi tiết nội dung thông báo..."
                  required
                  style={{ resize: 'vertical', fontFamily: 'inherit' }}
                  value={formData.content}
                  onChange={(e) => setFormData({ ...formData, content: e.target.value })}
                />
              </div>

              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px' }}>
                <div className="form-group">
                  <label className="form-label">Danh mục</label>
                  <select
                    className="form-control form-select"
                    value={formData.category}
                    onChange={(e) => setFormData({ ...formData, category: e.target.value })}
                  >
                    <option value="Thông báo chung">Thông báo chung</option>
                    <option value="Học tập">Học tập</option>
                    <option value="Học phí">Học phí</option>
                    <option value="Hoạt động">Hoạt động</option>
                  </select>
                </div>

                <div className="form-group">
                  <label className="form-label">Đối tượng gửi *</label>
                  <select
                    className="form-control form-select"
                    value={formData.targetGroup}
                    onChange={(e) => setFormData({ ...formData, targetGroup: e.target.value })}
                    required
                  >
                    <option value="ALL">Gửi tất cả (Mọi người)</option>
                    <option value="STUDENT">Chỉ Học sinh</option>
                    <option value="TEACHER">Chỉ Giáo viên</option>
                    <option value="PARENT">Chỉ Phụ huynh</option>
                  </select>
                </div>
              </div>

              <div style={{ display: 'flex', gap: '12px', justifyContent: 'flex-end', marginTop: '12px' }}>
                <button type="button" className="btn btn-secondary" onClick={handleCloseModal}>
                  Hủy
                </button>
                <button type="submit" className="btn btn-primary">
                  Gửi thông báo
                </button>
              </div>
            </div>
          </form>
        </div>
      </dialog>
    </div>
  );
}
