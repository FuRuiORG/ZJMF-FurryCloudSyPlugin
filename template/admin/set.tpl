<style>
    .cycles-setting .form-group>div{
        display: flex;        align-items: center;
    }
</style>
<section class="admin-main">
    <div class="container-fluid">
        <div class="page-container">
            <div class="card">
                <div class="card-body">
                    <!-- class="col-lg-1 col-md-12 col-sm-12" -->
                    <div class="card-title row">
                        <div class="pl-4 pr-4">{$Title}</div>
                        <div class="col-lg-8 col-md-12 col-sm-12">
                            {foreach $PluginsAdminMenu as $v}
                                {if $v['custom']}
                                    <span  class="ml-2"><a  class="h5" href="{$v.url}" target="_blank">{$v.name}</a></span>
                                {else/}
                                    <span  class="ml-2"> <a  class="h5" href="{$v.url}">{$v.name}</a></span>
                                {/if}
                            {/foreach}
                        </div>
                    </div>


                    <div class="tab-content mt-4">

                        <div class="table-body" id="server-product"></div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>
<script src="/plugins/addons/{$GzhxPluginPath}/template/js/layer/layer.js"></script>
<script src="/plugins/addons/{$GzhxPluginPath}/template/js/pagination.js"></script>
<script>
    let queryToJson=function (hash){
        let str=hash?window.location.hash:window.location.search
        if( !str ) return { };
        if(str) str=str.substr(1);
        if( !str ) return { };
        let arr = str.split('&');
        let data={ };
        $.each( arr, function (k,v) {

            if(v.indexOf("=")>-1){
                let d=v.indexOf("=");
                data[ decodeURIComponent(v.substr(0,d)) ]=decodeURIComponent(v.substr(d+1));

            }

        } );
        return data;
    }
    let jsonToQuery=function (json){
        return  Object.keys(json).map(function (key) {
            return json[key]? (key + "=" + encodeURIComponent(json[key])):"";
        }).join("&");
    }
    let GzhxLoading=function(str){



        return layer.msg(str, {
            time: 0,
            icon:16,
            shade: 0.3,zIndex: layer.zIndex,
            success:function (layero) {

                layer.setTop(layero);

            }

        });

    }
    let ajax=function (option){
        let index=GzhxLoading(option.load||"加载中……")
        $.ajax({
                dataType: "json",
                type: option.type||"post",

                headers: {
                    "X-Requested-With": "XMLHttpRequest",

                },
                url: option.url||"",
                data:option.data,
                async:true,
                success: function (t) {

                    layer.close(index);

                    if( t.status==1 ){
                        if(option.success)  option.success(t.info);
                    }else{
                        if(option.error){
                            option.error(t.info);
                        }else{
                            layer.msg(t.info);
                        }
                    }
                },

                error: function (request, status, errorThrown) {
                    layer.close(index);
                    if(option.error){
                        option.error("网络错误，请重试");
                    }else{
                        layer.msg("网络错误，请重试");
                    }
                }
            }
        );
    }
    $(function (){
        let query=queryToJson();
        let allProducts = []; // 存储所有商品数据
        let importedProducts = []; // 存储已导入的商品ID
        let clientImportedProducts = {}; // 服务器返回的已导入商品
        let isLoading = false;
        let allLoaded = false;
        let addpageData = null;
        let MenuType = { };
        let Groups = [];
        let Menu = [];

        // 从本地存储加载已导入的商品
        function loadImportedProducts() {
            const stored = localStorage.getItem('imported_products_' + query.id);
            if (stored) {
                importedProducts = JSON.parse(stored);
            }
        }

        // 保存已导入的商品到本地存储
        function saveImportedProducts() {
            localStorage.setItem('imported_products_' + query.id, JSON.stringify(importedProducts));
        }

        // 检查商品是否已导入
        function isProductImported(productId) {
            // 同时检查服务器数据和本地存储
            return clientImportedProducts.hasOwnProperty(productId) || importedProducts.includes(productId);
        }

        // 初始化加载全部数据
        loadImportedProducts();
        loadAllProducts();

        // 加载全部数据
        function loadAllProducts() {
            if (isLoading || allLoaded) return;
            isLoading = true;
            let index = GzhxLoading("加载中……");

            if (!addpageData) {
                // 先获取addpage数据
                $.ajax({
                    url: './zjmf_finance_api/addpage?request_time=' + new Date().getTime(),
                    type: "GET",
                    success: function (addpage) {
                        addpageData = addpage;
                        // 初始化分组和菜单数据
                        initGroupsAndMenu(addpage);
                        // 再获取全部商品数据
                        getAllProductsData(index);
                    }
                });
            } else {
                // 直接获取全部商品数据
                getAllProductsData(index);
            }
        }

        // 初始化分组和菜单数据
        function initGroupsAndMenu(addpage) {
            Groups = [];
            Groups.push('<option value="">请选择分组</option>');
            Groups.push('<option value="-1">新建分组</option>');
            $.each(addpage.data.groupdata,function (k,v){
                Groups.push('<option value="'+v.id+'">'+v.name+'</option>')
            });

            Menu = [];
            MenuType = { };
            Menu.push('<option value="">请选择导航</option>');
            $.each(addpage.data.ptype,function (k,v){
                MenuType[v.name] = v.id;
                Menu.push('<option value="'+v.id+'">'+v.name+'</option>')
            });

            // 确保汇率有默认值，默认为1
            const rateValue = addpage.data.rate || '1';
            // 初始化页面控件
            $('#server-product').empty().html('<div style="padding: 20px;margin:10px;box-sizing: border-box;border: 1px solid #333333;"><h3>提示：新建分组在商品中【默认分组】下，如需要调整请导入后到商品列表中自行调整</h3>利润百分比(%)：<input type="text" name="profit" value="0">汇率：<input type="text" name="rate" value="'+rateValue+'"></div>');
        }

        // 获取全部商品数据
        function getAllProductsData(index) {
            $.ajax({
                url: './get_upstream_products?id='+query.id+'&languagesys=CN&request_time='+new Date().getTime(),
                type: "GET",
                success: function (t) {
                    if( t.status==200 ){
                        // 发送check请求获取已导入商品信息
                        ajax({
                            data:{
                                action:'check',
                                data:t
                            },
                            success:function (r){
                                layer.close(index);
                                isLoading = false;

                                // 存储服务器返回的已导入商品
                                clientImportedProducts = r.client;

                                // 合并服务器数据和本地存储数据
                                for (let productId in clientImportedProducts) {
                                    if (clientImportedProducts.hasOwnProperty(productId) && !importedProducts.includes(productId)) {
                                        importedProducts.push(productId);
                                    }
                                }
                                saveImportedProducts();

                                // 存储全部商品数据
                                allProducts = t.data;
                                // 渲染所有商品
                                renderAllProducts(t.data);
                                allLoaded = true;
                                // 添加已加载全部的提示
                                if ($('#all-loaded').length === 0) {
                                    $('#server-product').append('<div id="all-loaded" style="text-align: center; padding: 20px; color: #999;">已加载全部商品 (' + calculateTotalProducts(t.data) + ')</div>');
                                }
                            }
                        });
                    } else {
                        layer.close(index);
                        isLoading = false;
                        layer.msg(t.msg);
                    }
                },
                error: function (data) {
                    layer.close(index);
                    isLoading = false;
                    layer.msg("网络错误");
                }
            });
        }

        // 计算商品总数
        function calculateTotalProducts(data) {
            let total = 0;
            $.each(data, function(k, v) {
                if (v.products && v.products.length) {
                    total += v.products.length;
                }
            });
            return total;
        }

        // 渲染所有商品数据
        function renderAllProducts(productsData) {
            $.each( productsData,function (k,v){
                let type='';
                let html='<div style="padding: 20px;margin:10px;box-sizing: border-box;border: 1px solid #333333;"><table class="table table-bordered table-hover">';
                html +='<caption style="caption-side:top;">'+v.name+'：<select name="group'+v.id+'" class="group-select">'+Groups.join('')+'</select><select name="menu'+v.id+'">'+Menu.join('')+'</select> <button type="button" class="btn btn-danger btn-sm update-files" data-vid="'+v.id+'" data-type="'+v.name+'">批量导入</button></caption>';
                html +='<thead class="thead-light">' +
                    '<tr>' +
                    '<th class="checkbox" style="width: 100px;">' +
                    '<div class="custom-control custom-checkbox thead-checkbox">' +
                    '<input type="checkbox" class="custom-control-input" id="customCheckHead'+v.id+'" name="headCheckbox">' +
                    '<label class="custom-control-label" for="customCheckHead'+v.id+'">&nbsp;</label>' +
                    '</div>' +
                    '</th>' +
                    '<th style="width: 100px;">ID</th>' +
                    '<th style="width: 300px;">商品名称</th>' +
                    '<th>TYPE</th>' +
                    '<th>状态</th>' +
                    '</tr></thead><tbody>';
                $.each( v.products,function (kk,vv){
                    if(type==''){
                        type=vv.type;
                    }
                    const isImported = isProductImported(vv.id);
                    const checkboxDisabled = isImported ? 'disabled' : '';
                    const checkboxClass = isImported ? 'disabled-checkbox' : '';
                    const statusText = isImported ? '已导入' : '未导入';
                    const statusClass = isImported ? 'text-success' : 'text-danger';

                    html +='<tr>' +
                        '<td>'+(isImported ? '' : ('<div class="custom-control custom-checkbox ' + checkboxClass + '">' +
                        '<input type="checkbox" class="custom-control-input row-checkbox" value="'+vv.id+'" data-name="'+vv.name+'" data-vid="'+v.id+'" id="customCheck'+vv.id+'" ' + checkboxDisabled + '>' +
                        '<label class="custom-control-label" for="customCheck'+vv.id+'">&nbsp;</label>' +
                        '</div>'))+'</td>' +
                        '<td>'+vv.id+'</td>' +
                        '<td>'+vv.name+'</td>' +
                        '<td>'+vv.type+'</td>' +
                        '<td class="' + statusClass + '">' + statusText + '</td>' +
                        '</tr>';
                });
                html +='</tbody></table></div>';
                $('#server-product').append(html);
                switch (type){
                    case 'cdn':$('select[name="menu'+v.id+'"]').val(MenuType['云服务器']);break;
                    case 'cloud':$('select[name="menu'+v.id+'"]').val(MenuType['云服务器']);break;
                    case 'hostingaccount':$('select[name="menu'+v.id+'"]').val(MenuType['虚拟主机']);break;
                    case 'server':$('select[name="menu'+v.id+'"]').val(MenuType['独立服务器']);break;
                    case 'other':$('select[name="menu'+v.id+'"]').val(MenuType['其他']);break;
                }
            } );

            // 重新绑定事件
            $('.thead-checkbox').off('click').on('click',function (){
                let self=$(this),checked=self.find('input[type="checkbox"]').prop('checked');
                self.closest('table').find('input[type="checkbox"]:not(:disabled)').prop('checked',checked);
            });

            $('.update-files').off('click').on('click',function (){
                let self=$(this),
                    id=[],
                    group_id=self.prev('select').prev('select').val(),
                    menu=self.prev('select').val(),
                    profit=$('#server-product input[name="profit"]').val(),
                    rate=$('#server-product input[name="rate"]').val();
                if(!group_id){
                    layer.msg("请选择要加入的分组");
                    return false;
                }
                if(!menu){
                    layer.msg("请选择要加入的导航");
                    return false;
                }
                self.closest('table').find('tbody').find('input[type="checkbox"]:checked:not(:disabled)').each(function (){
                    let ids=$(this).val(),name=$(this).data('name');
                    id.push({
                        id:ids,
                        name:name
                    });
                });
                if(id.length<1){
                    layer.msg("请选择要同步的产品");
                    return false;
                }
                let query=queryToJson();
                let fd = new FormData();

                fd.append("upstream_price_value",parseInt(profit)+100);
                fd.append("ptype",menu);
                fd.append("zjmf_finance_api_id",query.id);
                fd.append("rate",rate);
                $.each(id,function (k,v){
                    fd.append("productnames["+v.id+"]",v.name);
                });
                let _save=function (gid){
                    fd.append("gid",gid);
                    let index=GzhxLoading("处理中……");
                    $.ajax({
                        url: './zjmf_finance_api/inputproduct?request_time='+new Date().getTime(),
                        type: "POST",
                        processData: false,
                        contentType: false,
                        data: fd,
                        xhr: function () {
                            myXhr = $.ajaxSettings.xhr();
                            if (myXhr.upload) {
                            }
                            return myXhr;
                        },
                        complete:function(t){
                            layer.close(index);
                            if( t.status!=200 ){
                                layer.msg("网络错误");
                            }
                        },
                        success: function (t) {
                            layer.close(index);
                            if( t.status==200 ){
                                // 标记商品为已导入
                                id.forEach(function(product) {
                                    if (!importedProducts.includes(product.id)) {
                                        importedProducts.push(product.id);
                                    }
                                    // 同时更新服务器返回的已导入商品对象
                                    clientImportedProducts[product.id] = true;
                                });
                                saveImportedProducts();

                                // 更新UI，禁用已导入商品的复选框
                                id.forEach(function(product) {
                                    $('#customCheck' + product.id).prop('disabled', true);
                                    $('#customCheck' + product.id).closest('tr').find('td:last').text('已导入').addClass('text-success').removeClass('text-danger');
                                    // 对于已导入的商品，完全移除复选框
                                    if ($('#customCheck' + product.id).length) {
                                        $('#customCheck' + product.id).closest('div').remove();
                                    }
                                });

                                layer.msg(t.msg);
                            }else{
                                layer.msg(t.msg);
                            }
                        },
                        fail: function (data) {
                            layer.msg("网络错误");
                        }
                    });
                };
                if(group_id-0>0){
                    _save(group_id);
                }else{
                    ajax({
                        data:{
                            action:'save',
                            name:self.data('type')
                        },success:function (gid){
                            $('.group-select').append('<option value="'+gid+'">'+self.data('type')+'</option>');
                            _save(gid);
                        }
                    });
                }
            });
        }
    });
</script>

