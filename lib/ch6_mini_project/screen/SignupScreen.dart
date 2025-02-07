import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // 라디오 버튼 상태 관리
  String? _selectedGender;

  // 체크박스 상태 관리
  bool _isKoreanSelected = false;
  bool _isChineseSelected = false;
  bool _isJapaneseSelected = false;

  // 토스트처럼 메시지 표시 (SnackBar)
  void _showToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('회원 가입')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              const TextField(decoration: InputDecoration(labelText: '이메일')),
              const SizedBox(height: 16),
              const TextField(decoration: InputDecoration(labelText: '패스워드')),
              const SizedBox(height: 16),
              const TextField(decoration: InputDecoration(labelText: '패스워드 확인')),
              const SizedBox(height: 16),

              // 라디오 버튼
              Row(
                children: [
                  Flexible(
                    child: RadioListTile<String>(
                      title: const Text('남자'),
                      value: '남자',
                      groupValue: _selectedGender,
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value;
                          _showToast(context, '성별: $_selectedGender');
                        });
                      },
                    ),
                  ),
                  Flexible(
                    child: RadioListTile<String>(
                      title: const Text('여자'),
                      value: '여자',
                      groupValue: _selectedGender,
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value;
                          _showToast(context, '성별: $_selectedGender');
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 체크박스
              Column(
                children: [
                  CheckboxListTile(
                    title: const Text('한식'),
                    value: _isKoreanSelected,
                    onChanged: (value) {
                      setState(() {
                        _isKoreanSelected = value ?? false;
                        _showToast(context, _isKoreanSelected ? '한식 선택됨' : '한식 선택 해제됨');
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('중식'),
                    value: _isChineseSelected,
                    onChanged: (value) {
                      setState(() {
                        _isChineseSelected = value ?? false;
                        _showToast(context, _isChineseSelected ? '중식 선택됨' : '중식 선택 해제됨');
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('일식'),
                    value: _isJapaneseSelected,
                    onChanged: (value) {
                      setState(() {
                        _isJapaneseSelected = value ?? false;
                        _showToast(context, _isJapaneseSelected ? '일식 선택됨' : '일식 선택 해제됨');
                      });
                    },
                  ),
                ],
              ),

              // 회원 가입 버튼
              ElevatedButton(
                onPressed: () {
                  String selectedFood = '';
                  if (_isKoreanSelected) selectedFood += '한식 ';
                  if (_isChineseSelected) selectedFood += '중식 ';
                  if (_isJapaneseSelected) selectedFood += '일식 ';

                  final message =
                      '성별: ${_selectedGender ?? "선택 안됨"}\n선호 음식: ${selectedFood.isEmpty ? "선택 안됨" : selectedFood}';
                  _showToast(context, message);
                },
                child: const Text('회원 가입'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
