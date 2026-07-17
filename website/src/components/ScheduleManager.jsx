import React, { useState, useEffect, useRef } from 'react';
import { api } from '../utils/api';

const DAYS_OF_WEEK = {
  2: 'Thứ Hai',
  3: 'Thứ Ba',
  4: 'Thứ Tư',
  5: 'Thứ Năm',
  6: 'Thứ Sáu',
  7: 'Thứ Bảy',
  8: 'Chủ Nhật'
};

export default function ScheduleManager({ showToast }) {
  const [schedules, setSchedules] = useState([]);
  const [subjects, setSubjects] = useState([]);
  const [teachers, setTeachers] = useState([]);
  const [students, setStudents] = useState([]);
  
  const [loading, setLoading] = useState(false);
  const [filterDay, setFilterDay] = useState('ALL');
  const [searchTerm, setSearchTerm] = useState('');

  // Modal states
  const [isEditMode, setIsEditMode] = useState(false);
  const [selectedSchedule, setSelectedSchedule] = useState(null);
  const [formData, setFormData] = useState({
    dayOfWeek: 2,
    startTime: '07:30',
    endTime: '09:00',
    room: '',
    status: 'Sắp học',
    subjectId: '',
    teacherId: '',
    studentId: ''
  });

  const dialogRef = useRef(null);

  useEffect(() => {
    fetchSchedules();
    fetchDropdowns();
  }, []);

  const fetchSchedules = async () => {
    setLoading(true);
    try {
      const data = await api.getSchedules();
      setSchedules(data);
    } catch (err) {
      showToast(err.message, 'error');
    } finally {
      setLoading(false);
    }
  };

  const fetchDropdowns = async () => {
    try {
      const subs = await api.getSubjects();
      setSubjects(subs);
      
      const tc = await api.getTeachers();
      setTeachers(tc);

      const st = await api.getStudents();
      setStudents(st);
    } catch (err) {
      console.error('Failed to load dropdowns', err);
    }
  };

  const handleOpenAddModal = () => {
    setIsEditMode(false);
    setSelectedSchedule(null);
    setFormData({
      dayOfWeek: 2,
      startTime: '07:30',
      endTime: '08:15',
      room: '',
      status: 'Sắp học',
      subjectId: subjects[0]?.id || '',
      teacherId: teachers[0]?.id || '',
      studentId: students[0]?.id || ''
    });
    dialogRef.current?.showModal();
  };

  const handleOpenEditModal = (schedule) => {
    setIsEditMode(true);
    setSelectedSchedule(schedule);
    setFormData({
      dayOfWeek: schedule.dayOfWeek,
      startTime: schedule.startTime.substring(0, 5),
      endTime: schedule.endTime.substring(0, 5),
      room: schedule.room,
      status: schedule.status || 'Sắp học',
      subjectId: schedule.subjectId,
      teacherId: schedule.teacherId,
      studentId: schedule.studentId
    });
    dialogRef.current?.showModal();
  };

  const handleCloseModal = () => {
    dialogRef.current?.close();
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      if (isEditMode && selectedSchedule) {
        await api.updateSchedule(selectedSchedule.id, formData);
        showToast('Cập nhật lịch học thành công', 'success');
      } else {
        await api.createSchedule(formData);
        showToast('Tạo lịch học thành công', 'success');
      }
      handleCloseModal();
      fetchSchedules();
    } catch (err) {
      showToast(err.message, 'error');
    }
  };

  const handleDelete = async (id) => {
    if (!window.confirm('Bạn có chắc chắn muốn xóa lịch học này?')) {
      return;
    }
    try {
      await api.deleteSchedule(id);
      showToast('Xóa lịch học thành công', 'success');
      fetchSchedules();
    } catch (err) {
      showToast(err.message, 'error');
    }
  };

  const filteredSchedules = schedules.filter(s => {
    const term = searchTerm.toLowerCase();
    const matchesSearch = s.studentName.toLowerCase().includes(term) ||
                          s.teacherName.toLowerCase().includes(term) ||
                          s.subjectName.toLowerCase().includes(term) ||
                          s.room.toLowerCase().includes(term);
    const matchesDay = filterDay === 'ALL' || s.dayOfWeek.toString() === filterDay;
    return matchesSearch && matchesDay;
  });

  return (
    <div>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px', flexWrap: 'wrap', gap: '16px' }}>
        <div>
          <h2 style={{ fontSize: '1.5rem', marginBottom: '4px' }}>Quản lý lịch học (Schedule)</h2>
          <p style={{ color: 'var(--text-secondary)', fontSize: '0.9rem' }}>Sắp xếp, quản lý lịch giảng dạy của giáo viên và thời khóa biểu của học sinh</p>
        </div>
        <button className="btn btn-primary" onClick={handleOpenAddModal} disabled={subjects.length === 0 || teachers.length === 0 || students.length === 0}>
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
            <line x1="12" y1="5" x2="12" y2="19"></line>
            <line x1="5" y1="12" x2="19" y2="12"></line>
          </svg>
          Thêm lịch học
        </button>
      </div>

      {/* Filter and Search */}
      <div className="glass-card" style={{ padding: '16px', display: 'flex', gap: '16px', marginBottom: '20px', flexWrap: 'wrap' }}>
        <div style={{ flex: '1', minWidth: '200px' }}>
          <input
            type="text"
            className="form-control"
            placeholder="Tìm theo học sinh, giáo viên, môn học, phòng..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
          />
        </div>
        <div style={{ width: '180px' }}>
          <select className="form-control form-select" value={filterDay} onChange={(e) => setFilterDay(e.target.value)}>
            <option value="ALL">Tất cả các thứ</option>
            <option value="2">Thứ Hai</option>
            <option value="3">Thứ Ba</option>
            <option value="4">Thứ Tư</option>
            <option value="5">Thứ Năm</option>
            <option value="6">Thứ Sáu</option>
            <option value="7">Thứ Bảy</option>
          </select>
        </div>
      </div>

      {loading ? (
        <div style={{ textAlign: 'center', padding: '40px' }}>Đang tải dữ liệu lịch học...</div>
      ) : (
        <div className="table-container">
          <table className="admin-table">
            <thead>
              <tr>
                <th>Thứ</th>
                <th>Thời gian</th>
                <th>Môn học</th>
                <th>Phòng</th>
                <th>Giáo viên</th>
                <th>Học sinh</th>
                <th>Trạng thái</th>
                <th style={{ textAlign: 'right' }}>Hành động</th>
              </tr>
            </thead>
            <tbody>
              {filteredSchedules.length === 0 ? (
                <tr>
                  <td colSpan="8" style={{ textAlign: 'center', color: 'var(--text-secondary)', padding: '24px' }}>
                    Không tìm thấy lịch học nào phù hợp
                  </td>
                </tr>
              ) : (
                filteredSchedules.map(sch => (
                  <tr key={sch.id}>
                    <td style={{ fontWeight: '600' }}>{DAYS_OF_WEEK[sch.dayOfWeek] || `Thứ ${sch.dayOfWeek}`}</td>
                    <td style={{ fontWeight: '500' }}>{sch.startTime.substring(0, 5)} - {sch.endTime.substring(0, 5)}</td>
                    <td>
                      <span style={{ fontWeight: '500' }}>{sch.subjectName}</span>
                      <div style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>{sch.subjectCode}</div>
                    </td>
                    <td>{sch.room}</td>
                    <td>{sch.teacherName}</td>
                    <td style={{ fontWeight: '500', color: 'var(--color-purple)' }}>{sch.studentName}</td>
                    <td>
                      <span className={`badge ${sch.status === 'Đã học' ? 'badge-student' : 'badge-parent'}`}>
                        {sch.status || 'Sắp học'}
                      </span>
                    </td>
                    <td style={{ textAlign: 'right' }}>
                      <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '8px' }}>
                        <button className="btn btn-secondary btn-sm" onClick={() => handleOpenEditModal(sch)}>
                          Sửa
                        </button>
                        <button className="btn btn-danger btn-sm" onClick={() => handleDelete(sch.id)}>
                          Xóa
                        </button>
                      </div>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      )}

      {/* Add/Edit Modal */}
      <dialog ref={dialogRef}>
        <div className="modal-content" style={{ maxWidth: '600px' }}>
          <div className="modal-header">
            <h3 className="modal-title">{isEditMode ? 'Cập nhật lịch học' : 'Tạo mới lịch học'}</h3>
            <button className="modal-close" onClick={handleCloseModal}>
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <line x1="18" y1="6" x2="6" y2="18"></line>
                <line x1="6" y1="6" x2="18" y2="18"></line>
              </svg>
            </button>
          </div>
          <form onSubmit={handleSubmit}>
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px' }}>
              <div className="form-group">
                <label className="form-label">Thứ học *</label>
                <select
                  className="form-control form-select"
                  value={formData.dayOfWeek}
                  onChange={(e) => setFormData({ ...formData, dayOfWeek: parseInt(e.target.value) })}
                >
                  <option value="2">Thứ Hai</option>
                  <option value="3">Thứ Ba</option>
                  <option value="4">Thứ Tư</option>
                  <option value="5">Thứ Năm</option>
                  <option value="6">Thứ Sáu</option>
                  <option value="7">Thứ Bảy</option>
                </select>
              </div>

              <div className="form-group">
                <label className="form-label">Phòng học *</label>
                <input
                  type="text"
                  className="form-control"
                  required
                  value={formData.room}
                  onChange={(e) => setFormData({ ...formData, room: e.target.value })}
                  placeholder="Ví dụ: Phòng A201"
                />
              </div>

              <div className="form-group">
                <label className="form-label">Giờ bắt đầu *</label>
                <input
                  type="time"
                  className="form-control"
                  required
                  value={formData.startTime}
                  onChange={(e) => setFormData({ ...formData, startTime: e.target.value })}
                />
              </div>

              <div className="form-group">
                <label className="form-label">Giờ kết thúc *</label>
                <input
                  type="time"
                  className="form-control"
                  required
                  value={formData.endTime}
                  onChange={(e) => setFormData({ ...formData, endTime: e.target.value })}
                />
              </div>

              <div className="form-group">
                <label className="form-label">Môn học *</label>
                <select
                  className="form-control form-select"
                  value={formData.subjectId}
                  onChange={(e) => setFormData({ ...formData, subjectId: e.target.value })}
                  required
                >
                  {subjects.map(sub => (
                    <option key={sub.id} value={sub.id}>{sub.name} ({sub.code})</option>
                  ))}
                </select>
              </div>

              <div className="form-group">
                <label className="form-label">Giáo viên giảng dạy *</label>
                <select
                  className="form-control form-select"
                  value={formData.teacherId}
                  onChange={(e) => setFormData({ ...formData, teacherId: e.target.value })}
                  required
                >
                  {teachers.map(t => (
                    <option key={t.id} value={t.id}>{t.fullName} ({t.specialization || 'Khác'})</option>
                  ))}
                </select>
              </div>

              <div className="form-group">
                <label className="form-label">Học sinh *</label>
                <select
                  className="form-control form-select"
                  value={formData.studentId}
                  onChange={(e) => setFormData({ ...formData, studentId: e.target.value })}
                  required
                >
                  {students.map(s => (
                    <option key={s.id} value={s.id}>{s.fullName} ({s.studentCode} - {s.className})</option>
                  ))}
                </select>
              </div>

              <div className="form-group">
                <label className="form-label">Trạng thái học tập</label>
                <select
                  className="form-control form-select"
                  value={formData.status}
                  onChange={(e) => setFormData({ ...formData, status: e.target.value })}
                >
                  <option value="Sắp học">Sắp học</option>
                  <option value="Đang học">Đang học</option>
                  <option value="Đã học">Đã học</option>
                  <option value="Đã hủy">Đã hủy</option>
                </select>
              </div>
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
