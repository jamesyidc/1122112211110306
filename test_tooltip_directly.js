// 这个脚本可以在浏览器控制台直接运行来测试tooltip

console.log('\n🔍 开始测试tooltip中的正数占比显示...\n');

// 1. 检查window.positiveRatioStats
console.log('1️⃣ 检查 window.positiveRatioStats:');
console.log('   存在:', window.positiveRatioStats !== undefined);

if (window.positiveRatioStats) {
    console.log('   数据:', window.positiveRatioStats);
    console.log('   positive_ratio:', window.positiveRatioStats.positive_ratio);
    console.log('   positive_ratio !== undefined:', window.positiveRatioStats.positive_ratio !== undefined);
} else {
    console.log('   ❌ window.positiveRatioStats 不存在！');
}

// 2. 检查trendChart
console.log('\n2️⃣ 检查 trendChart:');
console.log('   存在:', typeof trendChart !== 'undefined');

if (typeof trendChart !== 'undefined') {
    const option = trendChart.getOption();
    console.log('   tooltip存在:', option.tooltip && option.tooltip.length > 0);
    console.log('   tooltip formatter类型:', typeof option.tooltip[0].formatter);
    
    // 3. 模拟tooltip formatter调用
    if (typeof option.tooltip[0].formatter === 'function') {
        console.log('\n3️⃣ 模拟调用tooltip formatter:');
        
        const mockParams = [{
            axisValue: '15:30:00',
            seriesName: '27币涨跌幅之和',
            value: -5.48,
            marker: '<span style="display:inline-block;margin-right:5px;border-radius:10px;width:10px;height:10px;background-color:#5470c6;"></span>',
            dataIndex: 0
        }];
        
        try {
            const html = option.tooltip[0].formatter(mockParams);
            console.log('   ✅ Formatter执行成功');
            console.log('   生成的HTML长度:', html.length);
            
            // 检查是否包含"正数占比"
            if (html.includes('正数占比') || html.includes('正数时段占比')) {
                console.log('   ✅ HTML中包含正数占比内容！');
                
                // 提取正数占比部分
                const match = html.match(/正数时段占比[\s\S]*?数据点/);
                if (match) {
                    console.log('   正数占比HTML片段:');
                    console.log(match[0]);
                }
            } else {
                console.log('   ❌ HTML中不包含正数占比内容');
                console.log('   完整HTML:', html);
            }
        } catch (error) {
            console.error('   ❌ Formatter执行失败:', error);
        }
    }
}

console.log('\n✅ 测试完成\n');
