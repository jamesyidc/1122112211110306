// ============================================================
// 🧪 Tooltip 正数占比验证脚本
// ============================================================
// 说明：在页面完全加载后，在浏览器控制台粘贴运行此脚本
// ============================================================

console.log('🔍 开始验证Tooltip正数占比功能...\n');

// 1. 检查数据是否加载
console.log('📊 步骤1：检查数据加载');
console.log('window.positiveRatioHistory 存在:', !!window.positiveRatioHistory);
if (window.positiveRatioHistory) {
    const keys = Object.keys(window.positiveRatioHistory);
    console.log('  数据点数量:', keys.length);
    console.log('  时间范围:', keys[0], '~', keys[keys.length - 1]);
    console.log('  样本数据（前3条）:');
    keys.slice(0, 3).forEach(time => {
        const data = window.positiveRatioHistory[time];
        console.log(`    ${time}: ${data.positive_ratio.toFixed(1)}% (${data.positive_count}/${data.total_count})`);
    });
} else {
    console.error('  ❌ window.positiveRatioHistory 未定义！');
}

// 2. 检查图表实例
console.log('\n📊 步骤2：检查图表实例');
console.log('trendChart 存在:', typeof trendChart !== 'undefined');
if (typeof trendChart !== 'undefined') {
    console.log('  trendChart.disposed:', trendChart._disposed);
    console.log('  trendChart.isDisposed():', trendChart.isDisposed());
    
    // 获取图表配置
    const option = trendChart.getOption();
    console.log('  tooltip 配置存在:', !!option.tooltip);
    console.log('  tooltip.formatter 类型:', typeof option.tooltip[0].formatter);
}

// 3. 模拟tooltip调用
console.log('\n📊 步骤3：模拟tooltip调用');
try {
    if (typeof trendChart !== 'undefined' && window.positiveRatioHistory) {
        const option = trendChart.getOption();
        const formatter = option.tooltip[0].formatter;
        
        // 获取第一个时间点
        const firstTime = Object.keys(window.positiveRatioHistory)[0];
        
        // 模拟params
        const mockParams = [{
            axisValue: firstTime,
            dataIndex: 0,
            seriesName: '27币涨跌幅之和',
            value: window.positiveRatioHistory[firstTime].total_change,
            marker: '<span style="display:inline-block;margin-right:4px;border-radius:10px;width:10px;height:10px;background-color:#3B82F6;"></span>'
        }];
        
        console.log('  测试时间点:', firstTime);
        console.log('  测试数据:', window.positiveRatioHistory[firstTime]);
        
        const tooltipHtml = formatter(mockParams);
        
        console.log('\n✅ Tooltip HTML生成成功！');
        console.log('  HTML长度:', tooltipHtml.length);
        console.log('  包含"正数时段占比":', tooltipHtml.includes('正数时段占比'));
        console.log('  包含正数占比值:', tooltipHtml.includes(window.positiveRatioHistory[firstTime].positive_ratio.toFixed(1) + '%'));
        
        // 显示HTML预览
        console.log('\n📋 Tooltip HTML预览（部分）:');
        const lines = tooltipHtml.split('\n').slice(0, 20);
        lines.forEach(line => console.log('  ' + line));
        
    } else {
        console.error('  ❌ 缺少必要的对象');
    }
} catch (error) {
    console.error('  ❌ 模拟调用失败:', error);
}

console.log('\n' + '='.repeat(60));
console.log('✅ 验证完成！');
console.log('\n💡 下一步：请将鼠标悬停在趋势图的蓝色曲线上，查看实际tooltip显示');
console.log('='.repeat(60));
