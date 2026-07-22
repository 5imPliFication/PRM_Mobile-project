import React, { useState, useEffect } from 'react';
import { api } from '../utils/api';
import AccountManager from './AccountManager';
import ClassManager from './ClassManager';
import StudentManager from './StudentManager';
import TeacherManager from './TeacherManager';
import ParentManager from './ParentManager';
import SubjectManager from './SubjectManager';
import ScheduleManager from './ScheduleManager';
import NotificationManager from './NotificationManager';

export default function Dashboard({ onLogout }) {
  const [activeTab, setActiveTab] = useState('dashboard');
  const [stats, setStats] = useState({
    totalAccounts: 0,
    totalStudents: 0,
    totalTeachers: 0,
    totalParents: 0,
    totalSchedules: 0
  });
  const [loadingStats, setLoadingStats] = useState(false);
  
  // Toast state
  const [toast, setToast] = useState({ message: '', type: '', visible: false });

  const showToast = (message, type = 'success') => {
    setToast({ message, type, visible: true });
    setTimeout(() => {
      setToast({ message: '', type: '', visible: false });
    }, 3500);
  };

  useEffect(() => {
    if (activeTab === 'dashboard') {
      fetchStats();
    }
  }, [activeTab]);

  const fetchStats = async () => {
    setLoadingStats(true);
    try {
      const data = await api.getStats();
      setStats(data);
    } catch (err) {
      showToast(err.message, 'error');
    } finally {
      setLoadingStats(false);
    }
  };

  const handleLogoutClick = () => {
    localStorage.removeItem('jwt_token');
    localStorage.removeItem('user_role');
    localStorage.removeItem('user_name');
    onLogout();
  };

  const adminName = localStorage.getItem('user_name') || 'Quản trị viên';
  const adminPhone = '0900000000';

  const renderTabContent = () => {
    switch (activeTab) {
      case 'accounts':
        return <AccountManager showToast={showToast} />;
      case 'classes':
        return <ClassManager showToast={showToast} />;
      case 'students':
        return <StudentManager showToast={showToast} />;
      case 'teachers':
        return <TeacherManager showToast={showToast} />;
      case 'parents':
        return <ParentManager showToast={showToast} />;
      case 'subjects':
        return <SubjectManager showToast={showToast} />;
      case 'schedules':
        return <ScheduleManager showToast={showToast} />;
      case 'notifications':
        return <NotificationManager showToast={showToast} />;
      case 'dashboard':
      default:
        return renderStatsHome();
    }
  };

  const renderStatsHome = () => {
    return (
      <div>
        <div style={{ marginBottom: '24px' }}>
          <h2 style={{ fontSize: '1.5rem', marginBottom: '4px' }}>Chào mừng trở lại, {adminName}</h2>
          <p style={{ color: 'var(--text-secondary)', fontSize: '0.9rem' }}>Tổng quan dữ liệu học đường hiện tại</p>
        </div>

        {loadingStats ? (
          <div style={{ textAlign: 'center', padding: '40px' }}>Đang cập nhật số liệu...</div>
        ) : (
          <div style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(auto-fit, minmax(220px, 1fr))',
            gap: '20px',
            marginBottom: '40px'
          }}>
            {/* Accounts Card */}
            <div className="glass-card" style={{ cursor: 'pointer' }} onClick={() => setActiveTab('accounts')}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px' }}>
                <div style={{
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  width: '44px',
                  height: '44px',
                  borderRadius: '10px',
                  background: 'rgba(243, 111, 33, 0.1)',
                  color: 'var(--color-accent)'
                }}>
                  <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                    <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path>
                    <circle cx="9" cy="7" r="4"></circle>
                    <path d="M23 21v-2a4 4 0 0 0-3-3.87"></path>
                    <path d="M16 3.13a4 4 0 0 1 0 7.75"></path>
                  </svg>
                </div>
                <span style={{ fontSize: '0.8rem', color: 'var(--color-success)', fontWeight: '600', padding: '4px 8px', background: 'rgba(16, 185, 129, 0.1)', borderRadius: '9999px' }}>
                  100% Active
                </span>
              </div>
              <h3 style={{ fontSize: '2rem', fontWeight: '700', marginBottom: '4px' }}>{stats.totalAccounts}</h3>
              <p style={{ color: 'var(--text-secondary)', fontSize: '0.9rem', fontWeight: '500' }}>Tài khoản người dùng</p>
            </div>

            {/* Students Card */}
            <div className="glass-card" style={{ cursor: 'pointer' }} onClick={() => setActiveTab('students')}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px' }}>
                <div style={{
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  width: '44px',
                  height: '44px',
                  borderRadius: '10px',
                  background: 'rgba(16, 185, 129, 0.1)',
                  color: 'var(--color-success)'
                }}>
                  <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                    <path d="M22 10v6M2 10l10-5 10 5-10 5z"></path>
                    <path d="M6 12v5c0 2 2 3 6 3s6-1 6-3v-5"></path>
                  </svg>
                </div>
                <span style={{ fontSize: '0.8rem', color: 'var(--text-secondary)' }}>Hồ sơ học tập</span>
              </div>
              <h3 style={{ fontSize: '2rem', fontWeight: '700', marginBottom: '4px' }}>{stats.totalStudents}</h3>
              <p style={{ color: 'var(--text-secondary)', fontSize: '0.9rem', fontWeight: '500' }}>Học sinh đang học</p>
            </div>

            {/* Teachers Card */}
            <div className="glass-card" style={{ cursor: 'pointer' }} onClick={() => setActiveTab('teachers')}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px' }}>
                <div style={{
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  width: '44px',
                  height: '44px',
                  borderRadius: '10px',
                  background: 'rgba(139, 92, 246, 0.1)',
                  color: 'var(--color-purple)'
                }}>
                  <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                    <path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"></path>
                    <path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"></path>
                  </svg>
                </div>
                <span style={{ fontSize: '0.8rem', color: 'var(--text-secondary)' }}>Giảng dạy</span>
              </div>
              <h3 style={{ fontSize: '2rem', fontWeight: '700', marginBottom: '4px' }}>{stats.totalTeachers}</h3>
              <p style={{ color: 'var(--text-secondary)', fontSize: '0.9rem', fontWeight: '500' }}>Giáo viên cơ hữu</p>
            </div>

            {/* Parents Card */}
            <div className="glass-card" style={{ cursor: 'pointer' }} onClick={() => setActiveTab('parents')}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px' }}>
                <div style={{
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  width: '44px',
                  height: '44px',
                  borderRadius: '10px',
                  background: 'rgba(245, 158, 11, 0.1)',
                  color: 'var(--color-warning)'
                }}>
                  <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                    <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path>
                  </svg>
                </div>
                <span style={{ fontSize: '0.8rem', color: 'var(--text-secondary)' }}>Đã bảo mật</span>
              </div>
              <h3 style={{ fontSize: '2rem', fontWeight: '700', marginBottom: '4px' }}>{stats.totalParents}</h3>
              <p style={{ color: 'var(--text-secondary)', fontSize: '0.9rem', fontWeight: '500' }}>Phụ huynh kết nối</p>
            </div>

            {/* Schedules Card */}
            <div className="glass-card" style={{ cursor: 'pointer' }} onClick={() => setActiveTab('schedules')}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px' }}>
                <div style={{
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  width: '44px',
                  height: '44px',
                  borderRadius: '10px',
                  background: 'rgba(255, 255, 255, 0.05)',
                  color: 'var(--text-primary)'
                }}>
                  <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                    <rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect>
                    <line x1="16" y1="2" x2="16" y2="6"></line>
                    <line x1="8" y1="2" x2="8" y2="6"></line>
                    <line x1="3" y1="10" x2="21" y2="10"></line>
                  </svg>
                </div>
                <span style={{ fontSize: '0.8rem', color: 'var(--text-secondary)' }}>Học kỳ Summer</span>
              </div>
              <h3 style={{ fontSize: '2rem', fontWeight: '700', marginBottom: '4px' }}>{stats.totalSchedules}</h3>
              <p style={{ color: 'var(--text-secondary)', fontSize: '0.9rem', fontWeight: '500' }}>Suất học / Lịch học</p>
            </div>
          </div>
        )}

        {/* Dynamic Quick actions grid */}
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1.2fr', gap: '20px', flexWrap: 'wrap' }}>
          <div className="glass-card" style={{ height: 'fit-content' }}>
            <h3 style={{ fontSize: '1.2rem', marginBottom: '16px' }}>Thông tin quản trị</h3>
            <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', borderBottom: '1px solid var(--border-color)', paddingBottom: '8px' }}>
                <span style={{ color: 'var(--text-secondary)' }}>Họ tên Admin</span>
                <span style={{ fontWeight: '500' }}>{adminName}</span>
              </div>
              <div style={{ display: 'flex', justifyContent: 'space-between', borderBottom: '1px solid var(--border-color)', paddingBottom: '8px' }}>
                <span style={{ color: 'var(--text-secondary)' }}>Số điện thoại</span>
                <span style={{ fontWeight: '500' }}>{adminPhone}</span>
              </div>
              <div style={{ display: 'flex', justifyContent: 'space-between', borderBottom: '1px solid var(--border-color)', paddingBottom: '8px' }}>
                <span style={{ color: 'var(--text-secondary)' }}>Cấp bậc quyền</span>
                <span className="badge badge-admin">Quản trị tối cao</span>
              </div>
              <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                <span style={{ color: 'var(--text-secondary)' }}>Môi trường hệ thống</span>
                <span style={{ fontWeight: '600', color: 'var(--color-accent)' }}>FPT School Cần Thơ</span>
              </div>
            </div>
          </div>

          <div className="glass-card">
            <h3 style={{ fontSize: '1.2rem', marginBottom: '16px' }}>Phím tắt nhanh</h3>
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px' }}>
              <button className="btn btn-secondary" style={{ justifyContent: 'flex-start', padding: '16px' }} onClick={() => setActiveTab('notifications')}>
                Tạo Thông báo
              </button>
              <button className="btn btn-secondary" style={{ justifyContent: 'flex-start', padding: '16px' }} onClick={() => setActiveTab('classes')}>
                Quản lý Lớp học
              </button>
              <button className="btn btn-secondary" style={{ justifyContent: 'flex-start', padding: '16px' }} onClick={() => setActiveTab('students')}>
                Quản lý Học sinh
              </button>
              <button className="btn btn-secondary" style={{ justifyContent: 'flex-start', padding: '16px' }} onClick={() => setActiveTab('teachers')}>
                Quản lý Giáo viên
              </button>
              <button className="btn btn-secondary" style={{ justifyContent: 'flex-start', padding: '16px' }} onClick={() => setActiveTab('schedules')}>
                Quản lý Lịch học
              </button>
              <button className="btn btn-secondary" style={{ justifyContent: 'flex-start', padding: '16px' }} onClick={() => setActiveTab('accounts')}>
                Quản lý Tài khoản
              </button>
            </div>
          </div>
        </div>
      </div>
    );
  };

  const navItems = [
    { id: 'dashboard', label: 'Dashboard', icon: (
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
        <rect x="3" y="3" width="7" height="9"></rect>
        <rect x="14" y="3" width="7" height="5"></rect>
        <rect x="14" y="12" width="7" height="9"></rect>
        <rect x="3" y="16" width="7" height="5"></rect>
      </svg>
    )},
    { id: 'notifications', label: 'Thông báo', icon: (
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
        <path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"></path>
        <path d="M13.73 21a2 2 0 0 1-3.46 0"></path>
      </svg>
    )},
    { id: 'accounts', label: 'Tài khoản', icon: (
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
        <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path>
        <circle cx="9" cy="7" r="4"></circle>
      </svg>
    )},
    { id: 'classes', label: 'Lớp học', icon: (
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
        <path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"></path>
        <path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"></path>
      </svg>
    )},
    { id: 'students', label: 'Học sinh', icon: (
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
        <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path>
        <circle cx="9" cy="7" r="4"></circle>
        <path d="M23 21v-2a4 4 0 0 0-3-3.87"></path>
        <path d="M16 3.13a4 4 0 0 1 0 7.75"></path>
      </svg>
    )},
    { id: 'teachers', label: 'Giáo viên', icon: (
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
        <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path>
      </svg>
    )},
    { id: 'parents', label: 'Phụ huynh', icon: (
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
        <path d="M12 2a5 5 0 1 0 10 10V2H12z"></path>
        <path d="M12 2a5 5 0 0 0-5 5v5a5 5 0 0 0 10 0V7"></path>
      </svg>
    )},
    { id: 'subjects', label: 'Môn học', icon: (
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
        <path d="M12 22c5.523 0 10-4.477 10-10S17.523 2 12 2 2 6.477 2 12s4.477 10 10 10z"></path>
        <path d="M12 6v6l4 2"></path>
      </svg>
    )},
    { id: 'schedules', label: 'Lịch học', icon: (
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
        <rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect>
        <line x1="16" y1="2" x2="16" y2="6"></line>
        <line x1="8" y1="2" x2="8" y2="6"></line>
        <line x1="3" y1="10" x2="21" y2="10"></line>
      </svg>
    )}
  ];

  return (
    <div style={{ display: 'flex', minHeight: '100vh', background: '#0a0b10' }}>
      
      {/* Sidebar Navigation */}
      <div style={{
        width: '260px',
        background: '#12131a',
        borderRight: '1px solid var(--border-color)',
        display: 'flex',
        flexDirection: 'column',
        padding: '24px 16px'
      }}>
        {/* Brand / Logo */}
        <div style={{ display: 'flex', alignItems: 'center', gap: '12px', padding: '0 8px', marginBottom: '32px' }}>
          <div style={{
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            width: '36px',
            height: '36px',
            borderRadius: '8px',
            background: 'var(--color-accent-gradient)'
          }}>
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="2.5">
              <path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5"/>
            </svg>
          </div>
          <div>
            <h1 style={{ fontSize: '1.25rem', fontWeight: '700', margin: 0 }}>FPT School</h1>
            <span style={{ fontSize: '0.75rem', color: 'var(--text-muted)', letterSpacing: '0.05em', textTransform: 'uppercase' }}>Admin Hub</span>
          </div>
        </div>

        {/* Menu items */}
        <nav style={{ display: 'flex', flexDirection: 'column', gap: '6px', flex: 1 }}>
          {navItems.map(item => {
            const isActive = activeTab === item.id;
            return (
              <button
                key={item.id}
                onClick={() => setActiveTab(item.id)}
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  gap: '12px',
                  width: '100%',
                  padding: '12px 16px',
                  background: isActive ? 'rgba(243, 111, 33, 0.08)' : 'transparent',
                  border: 'none',
                  borderRadius: '10px',
                  color: isActive ? 'var(--color-accent)' : 'var(--text-secondary)',
                  cursor: 'pointer',
                  fontSize: '0.95rem',
                  fontWeight: isActive ? '600' : '500',
                  textAlign: 'left',
                  transition: 'all 0.2s ease'
                }}
              >
                {item.icon}
                {item.label}
              </button>
            );
          })}
        </nav>

        {/* Logout Section */}
        <div style={{ borderTop: '1px solid var(--border-color)', paddingTop: '20px', marginTop: 'auto' }}>
          <button 
            className="btn btn-secondary" 
            style={{ width: '100%', justifyContent: 'flex-start', background: 'rgba(239, 68, 68, 0.05)', color: '#fca5a5', border: '1px solid rgba(239, 68, 68, 0.15)' }}
            onClick={handleLogoutClick}
          >
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
              <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"></path>
              <polyline points="16 17 21 12 16 7"></polyline>
              <line x1="21" y1="12" x2="9" y2="12"></line>
            </svg>
            Đăng xuất
          </button>
        </div>
      </div>

      {/* Main Content Area */}
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', overflowY: 'auto' }}>
        
        {/* Top Header */}
        <header style={{
          height: '70px',
          background: '#12131a',
          borderBottom: '1px solid var(--border-color)',
          display: 'flex',
          justifyContent: 'flex-end',
          alignItems: 'center',
          padding: '0 32px'
        }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
            <div style={{ textAlign: 'right' }}>
              <div style={{ fontWeight: '600', fontSize: '0.95rem' }}>{adminName}</div>
              <div style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>Quản trị viên</div>
            </div>
            <div style={{
              width: '40px',
              height: '40px',
              borderRadius: '9999px',
              background: 'var(--color-accent-gradient)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              fontWeight: 'bold',
              color: 'white',
              boxShadow: 'var(--shadow-sm)'
            }}>
              {adminName.substring(0, 1)}
            </div>
          </div>
        </header>

        {/* Page Content wrapper */}
        <main style={{ flex: 1, padding: '32px', maxWidth: '1200px', width: '100%', margin: '0 auto' }}>
          {renderTabContent()}
        </main>
      </div>

      {/* Toast Popup */}
      {toast.visible && (
        <div className="toast" style={{
          borderLeftColor: toast.type === 'error' ? 'var(--color-danger)' : 'var(--color-accent)'
        }}>
          {toast.type === 'error' ? (
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="var(--color-danger)" strokeWidth="2">
              <circle cx="12" cy="12" r="10"></circle>
              <line x1="12" y1="8" x2="12" y2="12"></line>
              <line x1="12" y1="16" x2="12.01" y2="16"></line>
            </svg>
          ) : (
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="var(--color-success)" strokeWidth="2">
              <polyline points="20 6 9 17 4 12"></polyline>
            </svg>
          )}
          <span>{toast.message}</span>
        </div>
      )}
    </div>
  );
}
