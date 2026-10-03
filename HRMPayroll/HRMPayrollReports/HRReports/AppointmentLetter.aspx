<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AppointmentLetter.aspx.cs" Inherits="Nexa_ERP.HRMPayroll.HRMPayrollReports.HRReports.AppointmentLetter" %>

<!DOCTYPE html>
<html lang="bn">
<head runat="server">
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<title>নিয়োগ পত্র / Appointment Letter</title>
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+Bengali:wght@400;700&display=swap" rel="stylesheet" />
<style>

@page{size:A4;margin:11mm 9mm 10mm 14mm}
*{box-sizing:border-box}
body{font-family:"Noto Sans Bengali","Nirmala UI","Vrinda","SolaimanLipi",serif;font-size:7.9pt;line-height:1.36;color:#000;margin:0}
.title{text-align:center;font-weight:700;font-size:14.5pt;line-height:1.3;margin-top:2mm}
.addr{text-align:center;font-size:8.6pt;margin-top:1mm;padding-bottom:1.6mm;border-bottom:1.1px solid #000}
.sub{text-align:center;font-size:11.5pt;margin-top:2.2mm;line-height:1.3}
.sub span{border-bottom:1px solid #000;padding-bottom:0.4mm}
.date{text-align:right;font-size:7.9pt;margin-top:0.5mm}
.row{display:flex}
.c1{width:52%}.c2{width:48%}
.row div{padding:0}
.ind{padding-left:18mm}
.subject{font-weight:700;text-decoration:underline;margin-top:0.2mm}
p{margin:0}
.tight{margin-top:0.6mm}
.pos{display:flex;margin-top:1mm}
.pos .a{width:40%}.pos .b{width:30%}.pos .c{width:30%}
.pos b{font-weight:700}
.wage{display:flex;margin-top:1mm}
.wage .l{width:60%}.wage .r{width:40%;padding-top:1mm}
.wage table{border-collapse:collapse;width:100%}
.wage td{padding:0;line-height:1.3}
.wage td.k{width:36%;padding-left:12mm}
.wage td.s{width:6%}
.wage td.v{width:20%}
.wage tr.tot td{border-top:1px solid #000}
.item{margin-top:0.4mm;text-align:justify}
.sub-i{padding-left:4mm}
.sig{display:flex;justify-content:space-between;font-size:8pt;margin-top:42mm}
.wrap{}
.en{font-family:"Liberation Serif","Times New Roman",serif;font-size:9pt}

@media screen{html{background:#e5e5e5}.sheet{width:210mm;margin:8mm auto;padding:11mm 9mm 10mm 14mm;background:#fff;box-shadow:0 0 6px rgba(0,0,0,.25)}}
@media print{.noprint{display:none!important}}
.noprint{position:fixed;top:10px;right:14px}.noprint button{padding:6px 14px;font-size:14px;cursor:pointer}
</style>
</head>
<body>
<form id="form1" runat="server">
<div class="noprint"><button type="button" onclick="window.print()">প্রিন্ট</button></div>
<div class="sheet">


<div class="title"><asp:Label ID="lblCompanyName" runat="server" Text="স্ট্যান্ডার্ড ক্লোথিং ইন্ডাস্ট্রিজ লিমিটেড" /></div>
<div class="addr"><asp:Label ID="lblCompanyAddress" runat="server" Text="৪৩/৩ ইব্রাহিমপুর, কাফরুল, মিরপুর-৪, ঢাকা ১২১৬, বাংলাদেশ" /></div>
<div class="sub"><span>(নিয়োগ পত্র / APPOINTMENT LETTER)</span></div>
<div class="date">তারিখ: <asp:Label ID="lblDate" runat="server" Text="০৪/১০/২০২৫" /> ইং</div>

<div class="row"><div style="width:100%">১। নাম: <span class="en">&nbsp;<asp:Label ID="lblName" runat="server" Text="Hafeza" /></span></div></div>
<div class="row"><div class="c1">২। পিতার নাম: <span class="en"><asp:Label ID="lblFather" runat="server" Text="Md. Tarikul Islam" /></span></div><div class="c2">৩। মাতার নাম: <span class="en">&nbsp;<asp:Label ID="lblMother" runat="server" Text="Mst. Anas Akter" /></span></div></div>
<div class="row"><div class="c1">৪। স্বামীর নাম (যদি থাকে): <span class="en"><asp:Label ID="lblHusband" runat="server" Text="" /></span></div><div class="c2">৫। স্ত্রীর নাম (যদি থাকে): <span class="en"><asp:Label ID="lblWife" runat="server" Text="" /></span></div></div>
<div class="row"><div class="c1">৬। ব্যক্তিগত মোবাইল নং: <asp:Label ID="lblMobile" runat="server" Text="০১৭৭৯৭১৩২৪৭" /></div><div class="c2">৭। জাতীয় পরিচয় পত্রের নং: <asp:Label ID="lblNID" runat="server" Text="২০০৭৪৮১৯২১৩১১৬৩০০" /></div></div>
<div class="row"><div class="c1">৮। বর্তমান &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;গ্রাম : <span class="en"><asp:Label ID="lblVillage" runat="server" Text="ibrahimpur" /></span></div><div class="c2">ডাকঘর :<span class="en"><asp:Label ID="lblPost" runat="server" Text="kafrul-1206" /></span></div></div>
<div class="row"><div class="c1" style="padding-left:18.5mm">থানা / উপজেলা <span class="en">&nbsp;<asp:Label ID="lblThana" runat="server" Text="kafrul" /></span></div><div class="c2" style="padding-left:4mm">জেলা :<span class="en"><asp:Label ID="lblDistrict" runat="server" Text="Dhaka North" /></span></div></div>
<div class="row"><div class="c1">৯। স্থায়ী &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;গ্রাম :<span class="en"><asp:Label ID="lblPVillage" runat="server" Text="Kajla" /></span></div><div class="c2">ডাকঘর :<span class="en"><asp:Label ID="lblPPost" runat="server" Text="Tarail" /></span></div></div>
<div class="row"><div class="c1" style="padding-left:18.5mm">থানা / উপজেলা <span class="en">&nbsp;<asp:Label ID="lblPThana" runat="server" Text="Kajla Damiha" /></span></div><div class="c2" style="padding-left:4mm">জেলা :<span class="en"><asp:Label ID="lblPDistrict" runat="server" Text="Kishoreganj" /></span></div></div>

<div class="subject">বিষয়: চাকুরীর নিয়োগপত্র।</div>
<p>জনাবা,</p>
<p>আপনার <asp:Label ID="lblApplyDate" runat="server" Text="০৪/১০/২০২৫" /> ইং তারিখের আবেদনপত্র ও &nbsp;সাক্ষাতের পরিপ্রেক্ষিতে আপনাকে <asp:Label ID="lblJoinDate" runat="server" Text="০৪/১০/২০২৫" /> ইং তারিখ হইতে নিম্ন বর্ণিত শর্ত সাপেক্ষে অত্র প্রতিষ্ঠানে নিয়োগ দেওয়া হলো:</p>

<div class="pos"><div class="a"><b>১০। আপনার বর্তমান পদবী:</b> <span class="en">&nbsp;<asp:Label ID="lblDesignation" runat="server" Text="Jr.Operator" /></span></div><div class="b">বিভাগ: <span class="en"><asp:Label ID="lblDepartment" runat="server" Text="Sewing Operator" /></span></div><div class="c"><b>সেকশন:</b> <span class="en"><asp:Label ID="lblSection" runat="server" Text="Sewing Operator" /></span></div></div>
<div class="pos" style="margin-top:0"><div class="a" style="padding-left:12mm"><b>আই ডি নং: <asp:Label ID="lblIDNo" runat="server" Text="৬৩" /></b></div><div class="b"><b>গ্রেড: <asp:Label ID="lblGrade" runat="server" Text="৩" /></b></div><div class="c">কাজের ধরণ: <asp:Label ID="lblWorkType" runat="server" Text="" /></div></div>

<p class="tight">১১। আপনার বর্তমান মাসিক মজুরী হবে নিম্নরূপ:</p>
<div class="wage"><div class="l"><table>
<tr><td class="k">মূল মজুরি</td><td class="s">:</td><td class="v"><asp:Label ID="lblBasic" runat="server" Text="0" /> /= টাকা</td><td></td></tr>
<tr><td class="k">বাড়ী ভাড়া</td><td class="s">:</td><td colspan="2"><asp:Label ID="lblHouse" runat="server" Text="0" /> /= টাকা (মূল মজুরীর <asp:Label ID="lblHousePct" runat="server" Text="৫০" />%)</td></tr>
<tr><td class="k">খাদ্য ভাতা</td><td class="s">:</td><td class="v"><asp:Label ID="lblFood" runat="server" Text="0" />/= টাকা</td><td></td></tr>
<tr><td class="k">যাতায়াত ভাতা</td><td class="s">:</td><td class="v"><asp:Label ID="lblTransport" runat="server" Text="0" />/= টাকা</td><td></td></tr>
<tr><td class="k">চিকিৎসা ভাতা</td><td class="s">:</td><td class="v"><asp:Label ID="lblMedical" runat="server" Text="0" />/= টাকা</td><td></td></tr>
<tr class="tot"><td class="k" style="border-top:1px solid #000;padding-top:0.3mm">সর্বমোট মজুরী</td><td class="s" style="padding-top:0.3mm">:</td><td class="v" style="padding-top:0.3mm"><asp:Label ID="lblTotal" runat="server" Text="0" /> /= টাকা</td><td></td></tr>
</table></div>
<div class="r"><p>* ওটি হার (প্রতি ঘন্টা): &nbsp;<asp:Label ID="lblOTRate" runat="server" Text="0" /> টাকা</p><p style="margin-top:1mm">* বাৎসরিক মজুরী বৃদ্ধি শ্রম আইন অনুযায়ী।</p></div></div>

<p class="tight">১২।</p>
<div class="item">১৩। <u>চাকুরীর অবসান :</u> কোন শ্রমিক মাসিক মজুরীর ভিত্তিতে নিয়োজিত থাকা অবস্থায় চাকুরীর অবসান করিতে চাহিলে স্থায়ী শ্রমিক ৬০ (ষাট) দিনের নোটিশ, অস্থায়ী শ্রমিক ৩০ (ত্রিশ) দিনের নোটিস এবং অন্যান্য শ্রমিক ১৪ (চৌদ্দ) দিনের নোটিশ নিয়োগ কর্তাকে প্রদান করিবেন। যদি উক্ত শ্রমিক উপরোক্ত দিন পূর্বে নোটিশ &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;দিতে ব্যর্থ হন তাহলে সংশ্লিষ্ট শ্রমিক নোটিশ মেয়াদের সমপরিমাণ মজুরীর অর্থ নিয়োগ কর্তাকে ফেরত দিতে বাধ্য থাকিবেন।</div>
<div class="item">১৪। <u>কর্ম সময়:</u> স্বাভাবিক কর্ম সময় দিনে ৮ (আট) ঘন্টা। কর্তৃপক্ষ প্রয়োজনবোধে আপনাকে অতিরিক্ত সময় কাজ করাতে পারবে (যা বাধ্যতামূলক নয়)। সেক্ষেত্রে অতিরিক্ত সময়ের মজুরীর দ্বিগুণ হারে মজুরী পরিশোধ করা হবে। যার হিসাব হবে এরূপ (মূল মজুরী/২০৮)×২× অতিরিক্ত কর্মঘন্টা। ফরন ভিত্তিক (পিস রেট) শ্রমিকের ক্ষেত্রে এই বিধান প্রযোজ্য হবে না।</div>
<div class="item">১৫। <u>ছুটি ও বন্ধ:</u> আপনি নিম্নে বর্ণিত হারে ছুটি পাবেন:</div>
<div class="item sub-i">ক) সাপ্তাহিক ছুটি: সপ্তাহে ০১ এক দিন (শুক্রবার অথবা সরকার নির্ধারিত আদেশ মোতাবেক)।</div>
<div class="item sub-i">খ) নৈমিত্তিক ছুটি: প্রতি পঞ্জিকা বৎসরে পূর্ণ মজুরীতে ১০ (দশ) দিন।</div>
<div class="item sub-i">গ) পীড়া ছুটি: প্রতি পঞ্জিকা বৎসরে পূর্ণ মজুরীতে ১৪ (চৌদ্দ) দিন।</div>
<div class="item sub-i">ঘ) বাৎসরিক ছুটি: প্রতি ১৮ দিন কাজের জন্য ১ (এক) দিন, তবে চাকুরীর মেয়াদ কমপক্ষে অবিচ্ছিন্ন ভাবে ০১ বৎসর পূর্ণ হলে এই ছুটি ভোগ করতে পারবেন এবং সর্বোচ্চ ৪০ দিন পর্যন্ত জমা করা যাবে।</div>
<div class="item sub-i">ঙ) উৎসব ছুটি: প্রতি পঞ্জিকা বৎসরে পূর্ণ মজুরীতে কমপক্ষে ১১ (এগার) দিন।</div>
<div class="item sub-i">চ) মাতৃকালীন ছুটি: পূর্ণ মজুরীতে ১২০ (একশত বিশ) দিন [শুধু মাত্র মহিলা শ্রমিকদের ক্ষেত্রে শ্রম আইন অনুযায়ী প্রযোজ্য]</div>
<div class="item">১৬। আহারের /বিশ্রামের বিরতি ১ ঘন্টা।</div>
<div class="item">১৭। আপনি যদি কখনো কোনরূপ অসদাচরনের অপরাধে দোষী প্রমানিত হন তবে কর্তৃপক্ষ আপনার বিরুদ্ধে আইনগত শাস্তিমূলক ব্যবস্থা গ্রহণ করিতে পারবে।</div>
<div class="item">১৮। আপনার চাকুরীতে যোগদানের বয়স ছয় (৬) মাস পূর্ণ হলে মোট বেতনের ১/৪ (চার ভাগের এক ভাগ) এবং ১ বছর পূর্ণ হলে মোট বেতনের ১/২ (অর্ধেক) হিসাবে উৎসব বোনাস প্রাপ্য হবেন। ১ বছর পূর্ণ হওয়া সাপেক্ষে প্রতি বছরে ২ (দুই) টি উৎসব বোনাস পাবেন।</div>
<div class="item">১৯। আপনি যদি কারখানায় বলিম্ব ব্যতিরেখে সঠিক সময়ে উপস্থিতি হন, তাহলে হাজিরা বোনাস মাসিক <asp:Label ID="lblAttBonus" runat="server" Text="০" /> টাকা প্রাপ্য হবেন। অনুমোদিত ছুটি কাটালেও ইহা পাবেন।</div>
<div class="item">২০। কোম্পানীর প্রয়োজনে স্ব-মালিকানাধীন অন্য যে কোন কারখানায় বদলী করিতে পারিবে।</div>
<div class="item">২১। আপনি আপনার ঠিকানা পরিবর্তন করিলে ৭ (সাত) দিনের মধ্যে অফিসকে লিখিত ভাবে জানাইতে হইবে।</div>
<div class="item">২২। সর্বোপরি আপনার চাকুরীর যাবতীয় শর্তাবলী বিদ্যমান শ্রম আইন অনুযায়ী পরিচালিত হবে।</div>
<div class="item">উপরে বর্ণিত শর্তাদি যদি আপনার গ্রহণ যোগ্য মনে হয় তবে আপনার সম্মতি স্বরূপ এই নিয়োগ পত্রের অনুলিপিতে স্বাক্ষর করে নিম্নে স্বাক্ষর কারীর নিকট ফেরত দিবেন।</div>
<div class="item">আমি এই নিয়োগ পত্রটি পড়ে এবং এতে বর্ণিত সম্পূর্ণ শর্ত সমূহ অবগত হয়ে সেচ্ছায় এবং স্বজ্ঞানে স্বাক্ষর করলাম এবং উক্ত নিয়োগ পত্রের এক কপি বুঝিয়া পাইলাম।</div>

<div class="sig"><div>শ্রমিকের স্বাক্ষর</div><div>নিয়োগকারীর স্বাক্ষর</div></div>

</div>
</form>
</body>
</html>
