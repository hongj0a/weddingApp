import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../config/ApiConstants.dart';
import '../../interceptor/api_service.dart';
import '../money/budget_setting.dart';

class BudgetCard extends StatefulWidget {
  const BudgetCard({super.key});

  @override
  State<BudgetCard> createState() => _BudgetCardState();
}

class _BudgetCardState extends State<BudgetCard> {
  final ApiService apiService = ApiService();
  int totalBudget = 0;
  int usedBudget = 0;
  int balanceBudget = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBudgetData();
  }

  Future<void> _fetchBudgetData() async {
    setState(() {
      isLoading = true; // 로딩 시작
      print('로딩 상태: 시작');
    });

    try {
      final response = await apiService.get(ApiConstants.getBudget);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data['data'];
        setState(() {
          totalBudget = data['totalAmount'] ?? 0;
          usedBudget = data['usedBudget'] ?? 0;
          balanceBudget = totalBudget - usedBudget;
          isLoading = false; // 로딩 완료
        });
      } else {
        print('Error fetching budget: ${response.statusCode}');
        setState(() {
          isLoading = false; // 로딩 완료
        });
      }
    } catch (e) {
      print('Fetch budget failed: $e');
      setState(() {
        isLoading = false; // 로딩 완료
        print('로딩 상태: 완료, 오류 발생: $e');
      });
    }
  }

  String _formatCurrency(String amount) {
    return amount.replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match match) => '${match[1]},');
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: Container());// 로딩 중
    }

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BudgetSetting()),
        );

        // BudgetSetting에서 true 값을 반환한 경우에만 새로고침
        if (result == true) {
          _fetchBudgetData();
        }
      },
      child: Container(
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.all(12.0),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 395,
                height: 200,
                child: SvgPicture.asset(
                  'asset/img/budget_card_no_line.svg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '예산',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildBudgetRow('총 예산', totalBudget),
                      const SizedBox(height: 8),
                      _buildBudgetRow('총 지출', usedBudget),
                      const SizedBox(height: 20),
                      Container(
                        height: 0.5,
                        color: Colors.white,
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                      ),
                      const SizedBox(height: 20),
                      _buildBudgetRow('남은 예산', balanceBudget),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetRow(String title, int amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        Text(
          '${_formatCurrency(amount.toString())} 원',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
