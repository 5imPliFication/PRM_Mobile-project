import React, { useState, useEffect, useRef } from 'react';
import { api } from '../utils/api';

export default function AccountManager({ showToast }) {
  const [accounts, setAccounts] = useState([]);
  const [loading, setLoading] = useState(false);
  const [searchTerm, setSearchTerm] = useState('');
  const [filterRole, setFilterRole] = useState('ALL');
  
  // Modal states
  const [isEditMode, setIsEditMode] = useState(false);
  const [selectedAccount, setSelectedAccount] = useState(null);
  const [formData, setFormData] = useState({
    phone: '',
    password: '',
    role: 'STUDENT',
    isActive: true
  });
  
  const dialogRef = useRef(null);

  useEffect(() => {
    fetchAccounts();
  }, []);

  const fetchAccounts = async () => {
    setLoading(true);
    try {
      const data = await api.getAccounts();
      setAccounts(data);
    } catch (err) {
      showToast(err.message, 'error');
    } finally {
      setLoading(false);
    }
  };

  const handleOpenAddModal = () => {
    setIsEditMode(false);
    setSelectedAccount(null);
    setFormData({
      phone: '',
      password: '',
      role: 'STUDENT',
      isActive: true
    });
    dialogRef.current?.showModal();
  };

  const handleOpenEditModal = (account) => {
    setIsEditMode(true);
    setSelectedAccount(account);
    setFormData({
      phone: account.phone,
      password: '',
      role: account.role,
      isActive: account.isActive
    });
    dialogRef.current?.showModal();
  };

  const handleCloseModal = () => {
    dialogRef.current?.close();
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      if (isEditMode && selectedAccount) {
        await api.updateAccount(selectedAccount.id, formData);
        showToast('Cập nhật tài khoản thành công', 'success');
      } else {
        if (!formData.password) {
          showToast('Mật khẩu không được để trống khi tạo tài khoản mới', 'error');
          return;
        }
        await api.createAccount(formData);
        showToast('Tạo tài khoản thành công', 'success');
      }
      handleCloseModal();
      fetchAccounts();
    } catch (err) {
      showToast(err.message, 'error');
    }
  };

  const handleDelete = async (id) => {
    if (!window.confirm('Bạn có chắc chắn muốn xóa tài khoản này? Thao tác này sẽ xóa các hồ sơ liên quan (học sinh/giáo viên/phụ huynh) và không thể hoàn tác.')) {
      return;
    }
    try {
      await api.deleteAccount(id);
      showToast('Xóa tài khoản thành công', 'success');
      fetchAccounts();
    } catch (err) {
      showToast(err.message, 'error');
    }
  };

  const filteredAccounts = accounts.filter(acc => {
    const matchesSearch = acc.phone.includes(searchTerm);
    const matchesFilter = filterRole === 'ALL' || acc.role === filterRole;
    return matchesSearch && matchesFilter;
  });

  const [currentPage, setCurrentPage] = useState(1);
  const itemsPerPage = 10;

  useEffect(() => {
    setCurrentPage(1);
  }, [searchTerm, filterRole]);

  const totalPages = Math.ceil(filteredAccounts.length / itemsPerPage);
  const startIndex = (currentPage - 1) * itemsPerPage;
  const paginatedAccounts = filteredAccounts.slice(startIndex, startIndex + itemsPerPage);

  return (
    <div>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px', flexWrap: 'wrap', gap: '16px' }}>
        <div>
          <h2 style={{ fontSize: '1.5rem', marginBottom: '4px' }}>Quản lý tài khoản</h2>
          <p style={{ color: 'var(--text-secondary)', fontSize: '0.9rem' }}>Xem và phân quyền các tài khoản đăng nhập</p>
        </div>
        <button className="btn btn-primary" onClick={handleOpenAddModal}>
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
            <line x1="12" y1="5" x2="12" y2="19"></line>
            <line x1="5" y1="12" x2="19" y2="12"></line>
          </svg>
          Thêm tài khoản
        </button>
      </div>

      {/* Filter and Search controls */}
      <div className="glass-card" style={{ padding: '16px', display: 'flex', gap: '16px', marginBottom: '20px', flexWrap: 'wrap' }}>
        <div style={{ flex: '1', minWidth: '200px' }}>
          <input
            type="text"
            className="form-control"
            placeholder="Tìm theo số điện thoại..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
          />
        </div>
        <div style={{ width: '180px' }}>
          <select className="form-control form-select" value={filterRole} onChange={(e) => setFilterRole(e.target.value)}>
            <option value="ALL">Tất cả vai trò</option>
            <option value="STUDENT">Học sinh</option>
            <option value="TEACHER">Giáo viên</option>
            <option value="PARENT">Phụ huynh</option>
            <option value="ADMIN">Quản trị viên</option>
          </select>
        </div>
      </div>

      {loading ? (
        <div style={{ textAlign: 'center', padding: '40px' }}>Đang tải dữ liệu tài khoản...</div>
      ) : (
        <>
          <div className="table-container">
            <table className="admin-table">
              <thead>
                <tr>
                  <th>Số điện thoại</th>
                  <th>Vai trò</th>
                  <th>Người liên kết</th>
                  <th>Trạng thái</th>
                  <th>Ngày tạo</th>
                  <th style={{ textAlign: 'right' }}>Hành động</th>
                </tr>
              </thead>
              <tbody>
                {filteredAccounts.length === 0 ? (
                  <tr>
                    <td colSpan="6" style={{ textAlign: 'center', color: 'var(--text-secondary)', padding: '24px' }}>
                      Không tìm thấy tài khoản nào phù hợp
                    </td>
                  </tr>
                ) : (
                  paginatedAccounts.map(acc => (
                    <tr key={acc.id}>
                      <td style={{ fontWeight: '600' }}>{acc.phone}</td>
                      <td>
                        <span className={`badge badge-${acc.role.toLowerCase()}`}>
                          {acc.role}
                        </span>
                      </td>
                      <td style={{ color: 'var(--text-secondary)', fontSize: '0.9rem' }}>
                        {acc.linkedName || <span style={{ fontStyle: 'italic', color: 'var(--text-muted)' }}>Chưa liên kết</span>}
                      </td>
                      <td>
                        <span className={`badge ${acc.isActive ? 'badge-active' : 'badge-inactive'}`}>
                          {acc.isActive ? 'Hoạt động' : 'Khóa'}
                        </span>
                      </td>
                      <td style={{ color: 'var(--text-secondary)', fontSize: '0.9rem' }}>
                        {new Date(acc.createdAt).toLocaleDateString('vi-VN')}
                      </td>
                      <td style={{ textAlign: 'right' }}>
                        <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '8px' }}>
                          <button className="btn btn-secondary btn-sm" onClick={() => handleOpenEditModal(acc)}>
                            Sửa
                          </button>
                          {acc.role !== 'ADMIN' && (
                            <button className="btn btn-danger btn-sm" onClick={() => handleDelete(acc.id)}>
                              Xóa
                          </button>
                          )}
                        </div>
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>

          {totalPages > 1 && (
            <div style={{
              display: 'flex',
              justifyContent: 'space-between',
              alignItems: 'center',
              marginTop: '20px',
              padding: '12px 20px',
              background: 'rgba(18, 19, 26, 0.4)',
              border: '1px solid var(--border-color)',
              borderRadius: 'var(--radius-sm)',
              flexWrap: 'wrap',
              gap: '12px'
            }}>
              <div style={{ fontSize: '0.9rem', color: 'var(--text-secondary)' }}>
                Hiển thị {startIndex + 1} - {Math.min(startIndex + itemsPerPage, filteredAccounts.length)} trong tổng số {filteredAccounts.length} mục
              </div>
              <div style={{ display: 'flex', gap: '6px' }}>
                <button
                  className="btn btn-secondary btn-sm"
                  onClick={() => setCurrentPage(prev => Math.max(prev - 1, 1))}
                  disabled={currentPage === 1}
                  style={{ padding: '6px 12px', minWidth: '40px' }}
                >
                  Trước
                </button>
                {Array.from({ length: totalPages }, (_, i) => i + 1).map(page => (
                  <button
                    key={page}
                    className={`btn ${currentPage === page ? 'btn-primary' : 'btn-secondary'} btn-sm`}
                    onClick={() => setCurrentPage(page)}
                    style={{
                      padding: '6px 12px',
                      minWidth: '36px',
                      background: currentPage === page ? 'var(--color-accent-gradient)' : 'rgba(255, 255, 255, 0.04)',
                      borderColor: currentPage === page ? 'var(--color-accent)' : 'var(--border-color)'
                    }}
                  >
                    {page}
                  </button>
                ))}
                <button
                  className="btn btn-secondary btn-sm"
                  onClick={() => setCurrentPage(prev => Math.min(prev + 1, totalPages))}
                  disabled={currentPage === totalPages}
                  style={{ padding: '6px 12px', minWidth: '40px' }}
                >
                  Sau
                </button>
              </div>
            </div>
          )}
        </>
      )}

      {/* Standard HTML Native Dialog for Add/Edit Form */}
      <dialog ref={dialogRef}>
        <div className="modal-content">
          <div className="modal-header">
            <h3 className="modal-title">{isEditMode ? 'Cập nhật tài khoản' : 'Tạo tài khoản mới'}</h3>
            <button className="modal-close" onClick={handleCloseModal}>
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <line x1="18" y1="6" x2="6" y2="18"></line>
                <line x1="6" y1="6" x2="18" y2="18"></line>
              </svg>
            </button>
          </div>
          <form onSubmit={handleSubmit}>
            <div className="form-group">
              <label className="form-label">Số điện thoại</label>
              <input
                type="text"
                className="form-control"
                required
                value={formData.phone}
                onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
                placeholder="Ví dụ: 0900000001"
              />
            </div>
            
            <div className="form-group">
              <label className="form-label">
                Mật khẩu {isEditMode && <span style={{ fontSize: '0.8rem', color: 'var(--text-secondary)' }}>(Để trống nếu không muốn đổi)</span>}
              </label>
              <input
                type="password"
                className="form-control"
                required={!isEditMode}
                value={formData.password}
                onChange={(e) => setFormData({ ...formData, password: e.target.value })}
                placeholder="Nhập mật khẩu"
              />
            </div>

            <div className="form-group">
              <label className="form-label">Vai trò</label>
              <select
                className="form-control form-select"
                value={formData.role}
                onChange={(e) => setFormData({ ...formData, role: e.target.value })}
              >
                <option value="STUDENT">Học sinh (STUDENT)</option>
                <option value="TEACHER">Giáo viên (TEACHER)</option>
                <option value="PARENT">Phụ huynh (PARENT)</option>
                <option value="ADMIN">Quản trị viên (ADMIN)</option>
              </select>
            </div>

            <div className="form-group" style={{ display: 'flex', alignItems: 'center', gap: '8px', marginTop: '12px' }}>
              <input
                type="checkbox"
                id="isActive"
                checked={formData.isActive}
                onChange={(e) => setFormData({ ...formData, isActive: e.target.checked })}
                style={{ width: '16px', height: '16px', accentColor: 'var(--color-accent)' }}
              />
              <label htmlFor="isActive" className="form-label" style={{ marginBottom: 0, cursor: 'pointer' }}>
                Kích hoạt tài khoản
              </label>
            </div>

            <div className="modal-footer">
              <button type="button" className="btn btn-secondary" onClick={handleCloseModal}>Hủy</button>
              <button type="submit" className="btn btn-primary">{isEditMode ? 'Cập nhật' : 'Tạo mới'}</button>
            </div>
          </form>
        </div>
      </dialog>
    </div>
  );
}
