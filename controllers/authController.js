// User �� �ҷ�����
const User = require('../models/userModel'); // ��θ� Ȯ���ϼ���

// �α��� ó�� �Լ�
exports.login = async (req, res) => {
    const { u_id, u_password } = req.body;

    try {
        // ����� ��ȸ
        const user = await User.findOne({ where: { u_id } });

        // ����ڰ� ���ų� ��й�ȣ�� ��ġ���� �ʴ� ���
        if (!user) {
            return res.status(401).json({ message: '�������� �ʴ� ������Դϴ�.' });
        }

        // ��й�ȣ ��ġ ���� Ȯ�� (�ܼ� ���ڿ� ��)
        if (u_password !== user.u_password) {
            return res.status(401).json({ message: '��й�ȣ�� ��ġ���� �ʽ��ϴ�.' });
        }

        // �α��� ���� �� ����
        return res.status(200).json({
            message: 'Login successful',
            user: {
                nickname: user.u_nickname,
                name: user.u_name,
                location: user.u_location,
                birth: user.u_birth,
            }
        });
    } catch (error) {
        console.error('�α��� ����:', error);
        res.status(500).json({ message: '���� ������ �߻��߽��ϴ�.' });
    }
};