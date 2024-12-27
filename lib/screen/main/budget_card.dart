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
      isLoading = true;
    });

    try {
      final response = await apiService.get(ApiConstants.getBudget);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data['data'];
        setState(() {
          totalBudget = data['totalAmount'] ?? 0;
          usedBudget = data['usedBudget'] ?? 0;
          balanceBudget = totalBudget - usedBudget;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  String _formatCurrency(String amount) {
    return amount.replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match match) => '${match[1]},');
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    if (isLoading) {
      return Center(child: Container()); // 로딩 중
    }

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BudgetSetting()),
        );

        if (result == true) {
          _fetchBudgetData();
        }
      },
      child: Container(
        margin: EdgeInsets.all(screenWidth * 0.02),
        padding: EdgeInsets.all(screenWidth * 0.03),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: screenWidth * 0.9,
                height: MediaQuery.of(context).orientation == Orientation.landscape && screenWidth >= 768
                    ? screenHeight * 0.40  // iPad 가로모드 (가로 크기가 768 이상일 때)
                    : screenHeight * 0.247,
                child: SvgPicture.asset(
                  'asset/img/budget_card_no_line.svg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.04),
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
                              fontSize: screenWidth * 0.057, // 화면 크기 비례 폰트 크기
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.03), // 화면 크기 비례 여백
                      _buildBudgetRow('총 예산', totalBudget),
                      SizedBox(height: screenHeight * 0.01), // 화면 크기 비례 여백
                      _buildBudgetRow('총 지출', usedBudget),
                      SizedBox(height: screenHeight * 0.02), // 화면 크기 비례 여백
                      Container(
                        height: 0.5,
                        color: Colors.white,
                        margin: EdgeInsets.symmetric(horizontal: 1),
                      ),
                      SizedBox(height: screenHeight * 0.02), // 화면 크기 비례 여백
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
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.0),
      child: Row(
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
      ),
    );
  }
}
