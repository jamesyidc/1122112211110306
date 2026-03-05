// ============================================================
// 🔍 检查浏览器加载的代码版本
// ============================================================
// 在浏览器控制台运行此脚本，检查是否加载了最新的tooltip代码
// ============================================================

console.clear();
console.log('=' .repeat(60));
console.log('🔍 检查Tooltip代码版本');
console.log('=' .repeat(60));

// 1. 检查trendChart是否存在
if (typeof trendChart === 'undefined') {
    console.error('❌ trendChart 未定义，页面可能还没加载完');
} else {
    console.log('✅ trendChart 已创建');
    
    try {
        // 2. 获取tooltip formatter函数
        const option = trendChart.getOption();
        const formatter = option.tooltip[0].formatter;
        
        // 3. 将函数转换为字符串，检查是否包含分钟匹配代码
        const formatterStr = formatter.toString();
        
        console.log('\n📋 Tooltip Formatter 代码检查:');
        console.log('-'.repeat(60));
        
        // 检查关键代码片段
        const checks = {
            '包含"正数时段占比"': formatterStr.includes('正数时段占比'),
            '包含分钟提取代码': formatterStr.includes('timeMinute') || formatterStr.includes('substring(0, 5)'),
            '包含分钟匹配代码': formatterStr.includes('startsWith(timeMinute)') || formatterStr.includes('find(key => key.startsWith'),
            '包含ratioData变量': formatterStr.includes('ratioData'),
            '包含正数占比检查日志': formatterStr.includes('正数占比检查')
        };
        
        let allPassed = true;
        Object.entries(checks).forEach(([name, passed]) => {
            console.log(`${passed ? '✅' : '❌'} ${name}`);
            if (!passed) allPassed = false;
        });
        
        console.log('\n' + '='.repeat(60));
        if (allPassed) {
            console.log('✅ 代码版本正确！已包含分钟级别匹配逻辑');
            console.log('\n💡 如果tooltip还是不显示，可能的原因:');
            console.log('   1. window.positiveRatioHistory 数据未加载');
            console.log('   2. 鼠标悬停的位置没有触发tooltip');
            console.log('   3. 数据格式问题');
            console.log('\n请在控制台查看是否有 "✅ 正数占比历史数据加载成功" 日志');
        } else {
            console.error('❌ 代码版本不正确！缺少分钟匹配逻辑');
            console.error('\n💡 解决方法:');
            console.error('   1. 清除浏览器缓存');
            console.error('   2. 使用无痕模式');
            console.error('   3. 硬刷新 (Ctrl+Shift+R)');
        }
        
        // 4. 显示formatter函数的前1000个字符
        console.log('\n📄 Formatter函数预览（前1000字符）:');
        console.log('-'.repeat(60));
        console.log(formatterStr.substring(0, 1000) + '...');
        
    } catch (e) {
        console.error('❌ 检查失败:', e.message);
    }
}

console.log('\n' + '='.repeat(60));
console.log('检查完成');
console.log('=' .repeat(60));
