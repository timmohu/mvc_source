package mohu.mvcs.injection;

import java.lang.annotation.*;

@Documented  
@Retention(RetentionPolicy.RUNTIME)  
@Target({ElementType.FIELD})
public @interface Inject {
	
	String value() default "";
	
}
