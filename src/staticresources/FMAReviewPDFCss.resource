p {margin : 0; line-height:1.5;}
.review {font-size:14px; position:relative; top:24px; page-break-after:always;}
.review:last-of-type {page-break-after:avoid;}
/*.review:before {content:'DRAFT'; position:absolute; padding:6px;background:#ccc; top:0; right:0; left:0; bottom:0; margin:auto;}*/
.accountInfo {margin-top:24px;}
.questions {float:left; width:75%;}
.answers {float:right; width:25%; text-align:right; margin-top:5px;}
.comments {font-style:italic; border:solid 1px; padding:3px 6px; margin-top:6px; width:132%;}
.checkboxGroup {}
.checkbox {height:10px; width:10px; border:solid 1px; display:inline-block; margin:0 3px;}
.checkbox.checked {background:black;}

.na {display:none;}

.header-left{position: running(header-left); margin:24px 0;}
.header-right {position: running(header-right); text-align:right; margin:24px 0;}
.footer-left {position: running(footer-left);}
.footer-right {position: running(footer-right); text-align:right;}


#pageNum:before {
       content: "(Page " counter(page) " of " counter(pages) ")";
 }

.hide {position:absolute; left:-99999px;}

@page {
  
  height:99%;
  size: letter;
  @top-left {
    content: element(header-left);
  }
  @top-right {
    content: element(header-right);
  }
  @bottom-left {
    content: element(footer-left);
  }
  @bottom-right {
    content: element(footer-right);
  }
}