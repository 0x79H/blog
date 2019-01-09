{% if page.comments %}
  <div class="comments" id="comments">
    {% if (theme.duoshuo and theme.duoshuo.shortname) or theme.duoshuo_shortname %}
      <div class="ds-thread" data-thread-key="{{ page.path }}"
           data-title="{{ page.title }}" data-url="{{ page.permalink }}">
      </div>
    {% elseif theme.disqus_shortname %}
      <div id="disqus_thread">
        <noscript>Please enable JavaScript to view the <a href="//disqus.com/?ref_noscript">comments powered by Disqus.</a></noscript>
        <script>document.write("<p>\u62b1\u6b49\u002c\u0020\u6839\u636e\u76f8\u5173\u6cd5\u5f8b\u6cd5\u89c4\u548c\u653f\u7b56\u002c\u0020\u60a8\u76ee\u524d\u53ea\u80fd\u6d4f\u89c8\u002c\u0020\u4e0d\u80fd\u8bc4\u8bba\u0028\u3000\u005e\u03c9\u005e\u0029</p>")</script>
      </div>
    {% endif %}
  </div>
{% endif %}
