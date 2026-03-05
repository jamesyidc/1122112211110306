// ============================================================
// 🔍 Tooltip正数占比完整诊断脚本
// ============================================================
// 使用方法：
// 1. 打开页面并硬刷新 (Ctrl+Shift+R)
// 2. 等待页面完全加载 (15-20秒)
// 3. 打开控制台 (F12)
// 4. 粘贴并运行此脚本
// ============================================================

console.clear();
console.log('=' .repeat(60));
console.log('🔍 Tooltip正数占比完整诊断');
console.log('=' .repeat(60));

// 步骤1: 检查数据加载状态
console.log('\n📊 步骤1: 检查数据加载状态');
console.log('-'.repeat(60));

if (typeof window.positiveRatioHistory === 'undefined') {
    console.error('❌ window.positiveRatioHistory 未定义！');
    console.log('💡 可能原因：');
    console.log('   1. 页面还没加载完');
    console.log('   2. 数据加载失败');
    console.log('   3. API请求出错');
    console.log('\n请等待页面完全加载后再运行此脚本');
} else {
    const dataCount = Object.keys(window.positiveRatioHistory).length;
    console.log(`✅ window.positiveRatioHistory 已加载`);
    console.log(`   数据点数量: ${dataCount}`);
    
    if (dataCount === 0) {
        console.error('❌ 数据为空！');
    } else {
        console.log(`✅ 数据正常 (${dataCount} 个时间点)`);
        
        // 显示前5个时间点
        const keys = Object.keys(window.positiveRatioHistory);
        console.log('\n   前5个时间点:');
        keys.slice(0, 5).forEach(time => {
            const data = window.positiveRatioHistory[time];
            console.log(`     ${time}: ${data.positive_ratio}% (${data.positive_count}/${data.total_count})`);
        });
        
        // 显示后5个时间点
        console.log('\n   后5个时间点:');
        keys.slice(-5).forEach(time => {
            const data = window.positiveRatioHistory[time];
            console.log(`     ${time}: ${data.positive_ratio}% (${data.positive_count}/${data.total_count})`);
        });
    }
}

// 步骤2: 检查图表实例
console.log('\n📊 步骤2: 检查图表实例');
console.log('-'.repeat(60));

if (typeof trendChart === 'undefined') {
    console.error('❌ trendChart 未定义！');
} else {
    console.log('✅ trendChart 已创建');
    
    try {
        const option = trendChart.getOption();
        const hasTooltip = option.tooltip && option.tooltip.length > 0;
        console.log(`   Tooltip配置: ${hasTooltip ? '✅ 存在' : '❌ 不存在'}`);
        
        if (hasTooltip) {
            const formatter = option.tooltip[0].formatter;
            console.log(`   Formatter类型: ${typeof formatter}`);
        }
    } catch (e) {
        console.error('❌ 获取图表配置失败:', e.message);
    }
}

// 步骤3: 模拟tooltip调用
console.log('\n📊 步骤3: 模拟tooltip调用');
console.log('-'.repeat(60));

if (typeof window.positiveRatioHistory !== 'undefined' && 
    Object.keys(window.positiveRatioHistory).length > 0 &&
    typeof trendChart !== 'undefined') {
    
    try {
        // 获取第一个时间点进行测试
        const testTime = Object.keys(window.positiveRatioHistory)[0];
        const testData = window.positiveRatioHistory[testTime];
        
        console.log(`   测试时间点: ${testTime}`);
        console.log(`   测试数据:`, testData);
        
        // 模拟tooltip formatter的params
        const mockParams = [{
            axisValue: testTime,
            dataIndex: 0,
            seriesName: '27币涨跌幅之和',
            value: testData.total_change || 0,
            marker: '<span style="display:inline-block;margin-right:4px;border-radius:10px;width:10px;height:10px;background-color:#3B82F6;"></span>'
        }];
        
        // 获取formatter并调用
        const option = trendChart.getOption();
        const formatter = option.tooltip[0].formatter;
        
        console.log('\n   调用tooltip formatter...');
        const tooltipHtml = formatter(mockParams);
        
        // 检查HTML是否包含正数占比
        const hasPositiveRatio = tooltipHtml.includes('正数时段占比');
        console.log(`   包含"正数时段占比": ${hasPositiveRatio ? '✅ 是' : '❌ 否'}`);
        
        if (hasPositiveRatio) {
            // 提取显示的百分比
            const ratioMatch = tooltipHtml.match(/(\d+\.\d+)%/g);
            console.log(`   ✅ Tooltip生成成功！`);
            console.log(`   显示的占比值: ${ratioMatch ? ratioMatch.join(', ') : '无法提取'}`);
        } else {
            console.error(`   ❌ Tooltip中没有"正数时段占比"！`);
            console.log('\n   Tooltip HTML预览（前500字符）:');
            console.log(tooltipHtml.substring(0, 500));
        }
        
    } catch (e) {
        console.error('❌ 模拟调用失败:', e.message);
        console.error(e.stack);
    }
} else {
    console.error('❌ 无法模拟，缺少必要的数据或图表实例');
}

// 步骤4: 测试特定时间点
console.log('\n📊 步骤4: 测试特定时间点');
console.log('-'.repeat(60));

const testTimes = ['01:00:36', '01:03:15', '02:00:10', '03:20:44'];

testTimes.forEach(time => {
    if (window.positiveRatioHistory && window.positiveRatioHistory[time]) {
        const data = window.positiveRatioHistory[time];
        console.log(`✅ ${time}: ${data.positive_ratio}% (${data.positive_count}/${data.total_count})`);
    } else {
        console.log(`❌ ${time}: 无数据`);
    }
});

// 总结
console.log('\n' + '='.repeat(60));
console.log('📋 诊断总结');
console.log('='.repeat(60));

const checks = {
    '数据加载': typeof window.positiveRatioHistory !== 'undefined' && Object.keys(window.positiveRatioHistory).length > 0,
    '图表实例': typeof trendChart !== 'undefined',
    'Tooltip配置': typeof trendChart !== 'undefined' && trendChart.getOption().tooltip && trendChart.getOption().tooltip.length > 0
};

console.log('\n检查项目:');
Object.entries(checks).forEach(([name, passed]) => {
    console.log(`   ${passed ? '✅' : '❌'} ${name}`);
});

if (Object.values(checks).every(v => v)) {
    console.log('\n✅ 所有检查通过！');
    console.log('💡 下一步: 将鼠标悬停在图表上，查看tooltip是否显示正数占比');
    console.log('💡 如果还是不显示，请提供控制台截图和tooltip截图');
} else {
    console.log('\n❌ 发现问题！');
    const failed = Object.entries(checks).filter(([_, v]) => !v).map(([k, _]) => k);
    console.log('   失败的检查: ' + failed.join(', '));
    console.log('💡 请等待页面完全加载后重新运行此脚本');
}

console.log('\n' + '='.repeat(60));
console.log('诊断完成');
console.log('='.repeat(60));
