// 在浏览器控制台运行这段代码来测试tooltip
console.log('=== Tooltip正数占比调试 ===');

// 1. 检查window.positiveRatioStats
console.log('1. window.positiveRatioStats:', window.positiveRatioStats);

// 2. 检查条件
if (window.positiveRatioStats) {
    console.log('   ✅ window.positiveRatioStats 存在');
    console.log('   positive_ratio:', window.positiveRatioStats.positive_ratio);
    console.log('   positive_ratio !== undefined:', window.positiveRatioStats.positive_ratio !== undefined);
    
    if (window.positiveRatioStats.positive_ratio !== undefined) {
        console.log('   ✅ 应该显示正数占比区域');
        
        // 3. 模拟tooltip HTML生成
        const positiveRatio = window.positiveRatioStats.positive_ratio;
        const positiveCount = window.positiveRatioStats.positive_count;
        const totalCount = window.positiveRatioStats.total_count;
        
        let html = '<div style="margin-top: 6px; padding: 6px; background: #F3F4F6; border-radius: 4px;">';
        html += '<div style="font-size: 12px; color: #6B7280;">今日正数时段占比</div>';
        html += `<div style="font-size: 14px; font-weight: bold; color: ${positiveRatio > 50 ? '#10B981' : '#EF4444'};">${positiveRatio.toFixed(1)}%</div>`;
        html += `<div style="font-size: 11px; color: #9CA3AF;">${positiveCount}/${totalCount} 数据点</div>`;
        html += '</div>';
        
        console.log('   生成的HTML:', html);
    } else {
        console.log('   ❌ positive_ratio 是 undefined');
    }
} else {
    console.log('   ❌ window.positiveRatioStats 不存在');
}

// 4. 检查图表是否存在
if (typeof trendChart !== 'undefined') {
    console.log('2. trendChart 存在');
} else {
    console.log('2. trendChart 不存在');
}

